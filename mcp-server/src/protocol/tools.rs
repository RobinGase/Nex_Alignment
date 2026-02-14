use crate::orchestration::parser::{parse_plan, TaskPlan};
use crate::{AgentDefinitions, AppState};
use anyhow::{anyhow, Context, Result};
use chrono::{Duration, Utc};
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::env;
use std::fs;
use std::path::PathBuf;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ToolDefinition {
    pub name: String,
    pub description: String,
    #[serde(rename = "inputSchema")]
    pub input_schema: Value,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReadAssignmentsInput {
    pub plan_id: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReadAssignmentsOutput {
    pub plan_id: String,
    pub assignments: Vec<AgentAssignment>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentAssignment {
    pub agent_id: String,
    pub files: Vec<String>,
    pub constraints: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RequestReviewInput {
    pub work_package: String,
    pub context: String,
    pub requesting_agent: String,
    pub target_agent: String,
    pub ack: Option<AckPayload>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RequestReviewOutput {
    pub request_id: String,
    pub deadline: String,
    pub lane_validation: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubmitReviewInput {
    pub request_id: String,
    pub findings: String,
    pub decision: String,
    pub reviewing_agent: String,
    pub ack: Option<AckPayload>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CheckStatusOutput {
    pub agents: Vec<AgentStatus>,
    pub pending_reviews: u32,
    pub completion_flag: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentStatus {
    pub agent_id: String,
    pub status: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AckPayload {
    pub request_id: Option<String>,
    pub target_agent: Option<String>,
    pub branch: Option<String>,
}

#[derive(Debug, Clone)]
struct AckValidation {
    mode: &'static str,
}

#[derive(Clone)]
pub struct ToolRegistry {
    tools: Vec<ToolDefinition>,
}

impl Default for ToolRegistry {
    fn default() -> Self {
        Self::new()
    }
}

impl ToolRegistry {
    pub fn new() -> Self {
        let tools = vec![
            ToolDefinition {
                name: "read_assignments".to_string(),
                description: "Read agent assignments from a task distribution plan".to_string(),
                input_schema: json!({
                    "type": "object",
                    "properties": {
                        "plan_id": {
                            "type": "string",
                            "description": "Plan ID to read assignments from (optional when only one plan exists)"
                        }
                    }
                }),
            },
            ToolDefinition {
                name: "request_review".to_string(),
                description: "Request a peer review from another agent".to_string(),
                input_schema: json!({
                    "type": "object",
                    "properties": {
                        "work_package": {
                            "type": "string",
                            "description": "Work package ID to review"
                        },
                        "context": {
                            "type": "string",
                            "description": "Review context and instructions"
                        },
                        "requesting_agent": {
                            "type": "string",
                            "description": "Agent requesting review"
                        },
                        "target_agent": {
                            "type": "string",
                            "description": "Agent receiving review request"
                        },
                        "ack": {
                            "type": "object",
                            "properties": {
                                "request_id": {"type": "string"},
                                "target_agent": {"type": "string"},
                                "branch": {"type": "string"}
                            },
                            "required": ["request_id", "target_agent", "branch"]
                        }
                    },
                    "required": ["work_package", "context", "requesting_agent", "target_agent", "ack"]
                }),
            },
            ToolDefinition {
                name: "submit_review".to_string(),
                description: "Submit review findings and decision".to_string(),
                input_schema: json!({
                    "type": "object",
                    "properties": {
                        "request_id": {
                            "type": "string",
                            "description": "Review request ID"
                        },
                        "findings": {
                            "type": "string",
                            "description": "Review findings"
                        },
                        "decision": {
                            "type": "string",
                            "enum": ["approve", "approved", "reject", "rejected", "conditional", "conditional_approval"],
                            "description": "Review decision"
                        },
                        "reviewing_agent": {
                            "type": "string",
                            "description": "Agent submitting the review"
                        },
                        "ack": {
                            "type": "object",
                            "properties": {
                                "request_id": {"type": "string"},
                                "target_agent": {"type": "string"},
                                "branch": {"type": "string"}
                            },
                            "required": ["request_id", "target_agent", "branch"]
                        }
                    },
                    "required": ["request_id", "findings", "decision", "reviewing_agent", "ack"]
                }),
            },
            ToolDefinition {
                name: "check_status".to_string(),
                description: "Check overall system status and completion".to_string(),
                input_schema: json!({
                    "type": "object",
                    "properties": {}
                }),
            },
        ];

        Self { tools }
    }

    pub fn list_all(&self) -> Vec<ToolDefinition> {
        self.tools.clone()
    }

    pub async fn call(
        &mut self,
        tool_name: &str,
        arguments: Value,
        state: &AppState,
    ) -> Result<Value> {
        match tool_name {
            "read_assignments" => self.handle_read_assignments(arguments).await,
            "request_review" => self.handle_request_review(arguments, state).await,
            "submit_review" => self.handle_submit_review(arguments, state).await,
            "check_status" => self.handle_check_status(state).await,
            _ => Err(anyhow!("Unknown tool: {}", tool_name)),
        }
    }

    async fn handle_read_assignments(&self, arguments: Value) -> Result<Value> {
        tracing::info!("Handling read_assignments with args: {}", arguments);

        let input: ReadAssignmentsInput =
            serde_json::from_value(arguments).context("invalid read_assignments arguments")?;

        let plan = load_plan_from_disk(input.plan_id.as_deref())?;

        let assignments = plan
            .assignees
            .into_iter()
            .map(|assignee| AgentAssignment {
                agent_id: assignee.agent_id,
                files: assignee.files,
                constraints: assignee.constraints,
            })
            .collect();

        let output = ReadAssignmentsOutput {
            plan_id: plan.plan_id,
            assignments,
        };

        Ok(json!(output))
    }

    async fn handle_request_review(&mut self, arguments: Value, state: &AppState) -> Result<Value> {
        tracing::info!("Handling request_review with args: {}", arguments);

        let input: RequestReviewInput =
            serde_json::from_value(arguments).context("invalid request_review arguments")?;

        let ack_validation = validate_ack(
            input.ack.as_ref(),
            &state.agent_definitions,
            &input.requesting_agent,
            Some(input.target_agent.as_str()),
            None,
            true,
            true,
        )?;

        let request_id = input
            .ack
            .as_ref()
            .and_then(|ack| ack.request_id.clone())
            .unwrap_or_else(|| Uuid::new_v4().to_string());

        state
            .session_manager
            .ensure_agent_exists(&input.requesting_agent)
            .await?;
        state
            .session_manager
            .ensure_agent_exists(&input.target_agent)
            .await?;

        let deadline = (Utc::now() + Duration::hours(24)).to_rfc3339();

        state
            .review_system
            .create_review_request_with_id(
                &request_id,
                &input.requesting_agent,
                &input.target_agent,
                &input.work_package,
                &input.context,
                "normal",
                &deadline,
            )
            .await?;

        let output = RequestReviewOutput {
            request_id,
            deadline,
            lane_validation: ack_validation.mode.to_string(),
        };

        Ok(json!(output))
    }

    async fn handle_submit_review(&mut self, arguments: Value, state: &AppState) -> Result<Value> {
        tracing::info!("Handling submit_review with args: {}", arguments);

        let input: SubmitReviewInput =
            serde_json::from_value(arguments).context("invalid submit_review arguments")?;

        let request_target = state
            .review_system
            .get_review_request_target(&input.request_id)
            .await?
            .ok_or_else(|| anyhow!("review request not found: {}", input.request_id))?;

        let (target_agent, current_status) = request_target;
        if current_status != "pending" {
            return Err(anyhow!(
                "review request {} is not pending (current status: {})",
                input.request_id,
                current_status
            ));
        }

        if input.reviewing_agent != target_agent {
            return Err(anyhow!(
                "reviewing_agent '{}' does not match request target_agent '{}'",
                input.reviewing_agent,
                target_agent
            ));
        }

        let ack_validation = validate_ack(
            input.ack.as_ref(),
            &state.agent_definitions,
            &input.reviewing_agent,
            Some(target_agent.as_str()),
            Some(input.request_id.as_str()),
            true,
            true,
        )?;

        state
            .session_manager
            .ensure_agent_exists(&input.reviewing_agent)
            .await?;

        let response_id = state
            .review_system
            .submit_review_response(
                &input.request_id,
                &input.reviewing_agent,
                &input.findings,
                &input.decision,
            )
            .await?;

        Ok(json!({
            "success": true,
            "review_submitted": true,
            "request_id": input.request_id,
            "response_id": response_id,
            "request_status": "completed",
            "lane_validation": ack_validation.mode,
        }))
    }

    async fn handle_check_status(&self, state: &AppState) -> Result<Value> {
        tracing::info!("Handling check_status");

        let agents = state
            .session_manager
            .list_agent_statuses()
            .await?
            .into_iter()
            .map(|status| AgentStatus {
                agent_id: status.agent_id,
                status: status.status,
            })
            .collect::<Vec<_>>();

        let pending_reviews = state.review_system.pending_review_count().await?;
        let completion_flag = pending_reviews == 0
            && !agents.is_empty()
            && agents.iter().all(|a| a.status == "completed");

        let output = CheckStatusOutput {
            agents,
            pending_reviews,
            completion_flag,
        };

        Ok(json!(output))
    }
}

fn load_plan_from_disk(plan_id: Option<&str>) -> Result<TaskPlan> {
    if let Ok(explicit_path) = env::var("NAP_MCP_PLANS_PATH") {
        let path = PathBuf::from(explicit_path);
        if !path.exists() {
            return Err(anyhow!(
                "NAP_MCP_PLANS_PATH does not exist: {}",
                path.display()
            ));
        }

        if path.is_dir() {
            return load_plan_from_dir(path, plan_id);
        }

        return load_plan_from_file(path, plan_id);
    }

    let plans_dir = env::var("NAP_MCP_PLANS_DIR")
        .map(PathBuf::from)
        .unwrap_or_else(|_| PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("plans"));

    load_plan_from_dir(plans_dir, plan_id)
}

fn load_plan_from_dir(plans_dir: PathBuf, plan_id: Option<&str>) -> Result<TaskPlan> {
    let entries = fs::read_dir(&plans_dir)
        .with_context(|| format!("failed to read plans directory: {}", plans_dir.display()))?;

    let mut plans = Vec::new();

    for entry in entries {
        let entry = entry?;
        let path = entry.path();

        let extension = path
            .extension()
            .and_then(|value| value.to_str())
            .unwrap_or("");
        if extension != "yaml" && extension != "yml" {
            continue;
        }

        let content = fs::read_to_string(&path)
            .with_context(|| format!("failed reading plan file {}", path.display()))?;
        let plan = parse_plan(&content)
            .with_context(|| format!("failed parsing plan file {}", path.display()))?;
        plans.push(plan);
    }

    if plans.is_empty() {
        return Err(anyhow!("no plan files found under plans/*.yaml"));
    }

    if let Some(plan_id) = plan_id {
        plans
            .into_iter()
            .find(|plan| plan.plan_id == plan_id)
            .ok_or_else(|| anyhow!("plan_id '{}' not found in plans directory", plan_id))
    } else if plans.len() == 1 {
        Ok(plans.remove(0))
    } else {
        Err(anyhow!(
            "multiple plan files found; specify plan_id to disambiguate"
        ))
    }
}

fn load_plan_from_file(plan_path: PathBuf, plan_id: Option<&str>) -> Result<TaskPlan> {
    let content = fs::read_to_string(&plan_path)
        .with_context(|| format!("failed reading plan file {}", plan_path.display()))?;
    let plan = parse_plan(&content)
        .with_context(|| format!("failed parsing plan file {}", plan_path.display()))?;

    if let Some(expected_plan_id) = plan_id {
        if plan.plan_id != expected_plan_id {
            return Err(anyhow!(
                "plan_id '{}' does not match plan file '{}' (actual plan_id '{}')",
                expected_plan_id,
                plan_path.display(),
                plan.plan_id
            ));
        }
    }

    Ok(plan)
}

fn validate_ack(
    ack: Option<&AckPayload>,
    definitions: &AgentDefinitions,
    actor_agent: &str,
    expected_target_agent: Option<&str>,
    expected_request_id: Option<&str>,
    enforce_target_match: bool,
    require_request_id: bool,
) -> Result<AckValidation> {
    if definitions.is_single_agent_fallback() {
        return Ok(AckValidation {
            mode: "single_agent_fallback",
        });
    }

    let ack = ack.ok_or_else(|| {
        anyhow!("ack is required in lane-enforced mode (request_id, target_agent, branch)")
    })?;

    let ack_target = ack
        .target_agent
        .as_deref()
        .ok_or_else(|| anyhow!("ack.target_agent is required"))?;
    let ack_branch = ack
        .branch
        .as_deref()
        .ok_or_else(|| anyhow!("ack.branch is required"))?;

    if let Some(expected_target_agent) = expected_target_agent {
        if !definitions.has_agent(expected_target_agent) {
            return Err(anyhow!(
                "unknown target agent in definitions: {}",
                expected_target_agent
            ));
        }

        if enforce_target_match && ack_target != expected_target_agent {
            return Err(anyhow!(
                "lane mismatch: ack.target_agent '{}' does not match expected target '{}'",
                ack_target,
                expected_target_agent
            ));
        }
    }

    let ack_request_id = ack.request_id.as_deref();

    if require_request_id && ack_request_id.is_none() {
        return Err(anyhow!("ack.request_id is required"));
    }

    if let Some(expected_request_id) = expected_request_id {
        let ack_request_id = ack_request_id.ok_or_else(|| anyhow!("ack.request_id is required"))?;
        if ack_request_id != expected_request_id {
            return Err(anyhow!(
                "ack.request_id mismatch: '{}' != '{}'",
                ack_request_id,
                expected_request_id
            ));
        }
    }

    if !definitions.has_agent(actor_agent) {
        return Err(anyhow!(
            "unknown actor agent in definitions: {}",
            actor_agent
        ));
    }

    let expected_branch = definitions
        .branch_for_agent(actor_agent)
        .ok_or_else(|| anyhow!("unknown actor agent lane: {}", actor_agent))?;

    if ack_branch != expected_branch {
        return Err(anyhow!(
            "out-of-lane execution rejected: branch '{}' does not match actor agent '{}' lane '{}'",
            ack_branch,
            actor_agent,
            expected_branch
        ));
    }

    Ok(AckValidation { mode: "enforced" })
}
