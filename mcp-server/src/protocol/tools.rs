use crate::AppState;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use anyhow::Result;
use chrono::Utc;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ToolDefinition {
    pub name: String,
    pub description: String,
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
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RequestReviewOutput {
    pub request_id: String,
    pub deadline: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubmitReviewInput {
    pub request_id: String,
    pub findings: String,
    pub decision: String,
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

#[derive(Clone)]
pub struct ToolRegistry {
    tools: Vec<ToolDefinition>,
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
                            "description": "Plan ID to read assignments from (optional)"
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
                        }
                    },
                    "required": ["work_package", "context"]
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
                            "enum": ["approve", "reject", "conditional"],
                            "description": "Review decision"
                        }
                    },
                    "required": ["request_id", "findings", "decision"]
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
    
    pub async fn call(&mut self, tool_name: &str, arguments: Value, state: &AppState) -> Result<Value> {
        match tool_name {
            "read_assignments" => self.handle_read_assignments(arguments, state).await,
            "request_review" => self.handle_request_review(arguments, state).await,
            "submit_review" => self.handle_submit_review(arguments, state).await,
            "check_status" => self.handle_check_status(arguments, state).await,
            _ => Err(anyhow::anyhow!("Unknown tool: {}", tool_name)),
        }
    }
    
    async fn handle_read_assignments(&self, arguments: Value, _state: &AppState) -> Result<Value> {
        tracing::info!("Handling read_assignments with args: {}", arguments);
        
        let plan_id = arguments.get("plan_id")
            .and_then(|v| v.as_str())
            .map(|s| s.to_string());
        
        // Mock data for now - would normally query from state.session_manager
        let output = ReadAssignmentsOutput {
            plan_id: plan_id.unwrap_or_else(|| "SESSION-2026-02-11".to_string()),
            assignments: vec![
                AgentAssignment {
                    agent_id: "agent-0".to_string(),
                    files: vec!["src/module_a/*".to_string(), "tests/module_a/*".to_string()],
                    constraints: vec!["no_modify_files_starting_with_B".to_string()],
                },
                AgentAssignment {
                    agent_id: "agent-1".to_string(),
                    files: vec!["src/module_b/*".to_string()],
                    constraints: vec!["only_read_module_a".to_string()],
                },
                AgentAssignment {
                    agent_id: "agent-2".to_string(),
                    files: vec!["docs/guide/*".to_string()],
                    constraints: vec!["no_code_modifications".to_string()],
                },
                AgentAssignment {
                    agent_id: "agent-3".to_string(),
                    files: vec!["src/integration/*".to_string()],
                    constraints: vec!["wait_for_all_others".to_string()],
                },
            ],
        };
        
        Ok(json!(output))
    }
    
    async fn handle_request_review(&mut self, arguments: Value, state: &AppState) -> Result<Value> {
        tracing::info!("Handling request_review with args: {}", arguments);
        
        let work_package = arguments.get("work_package")
            .and_then(|v| v.as_str())
            .ok_or_else(|| anyhow::anyhow!("Missing work_package"))?;
        
        let _context = arguments.get("context")
            .and_then(|v| v.as_str())
            .ok_or_else(|| anyhow::anyhow!("Missing context"))?;
        
        let request_id = Uuid::new_v4().to_string();
        let deadline = Utc::now() + chrono::Duration::hours(24);
        
        // Store review request in database
        let _ = state.review_system.create_review_request(
            "agent-0".to_string(),
            "agent-1".to_string(),
        ).await;
        
        let output = RequestReviewOutput {
            request_id: request_id.clone(),
            deadline: deadline.to_rfc3339(),
        };
        
        Ok(json!(output))
    }
    
    async fn handle_submit_review(&mut self, arguments: Value, _state: &AppState) -> Result<Value> {
        tracing::info!("Handling submit_review with args: {}", arguments);
        
        let request_id = arguments.get("request_id")
            .and_then(|v| v.as_str())
            .ok_or_else(|| anyhow::anyhow!("Missing request_id"))?;
        
        let _findings = arguments.get("findings")
            .and_then(|v| v.as_str())
            .ok_or_else(|| anyhow::anyhow!("Missing findings"))?;
        
        let _decision = arguments.get("decision")
            .and_then(|v| v.as_str())
            .ok_or_else(|| anyhow::anyhow!("Missing decision"))?;
        
        // Update review request in database
        // This would normally call a method on state.review_system
        
        Ok(json!({
            "success": true,
            "review_submitted": true,
            "request_id": request_id
        }))
    }
    
    async fn handle_check_status(&self, _arguments: Value, state: &AppState) -> Result<Value> {
        tracing::info!("Handling check_status");
        
        // Query agent statuses from session manager
        let mut agents = vec![];
        
        for i in 0..4 {
            let agent_id = format!("agent-{}", i);
            if let Some(status) = state.session_manager.get_agent_status(&agent_id).await? {
                agents.push(AgentStatus {
                    agent_id: status.agent_id,
                    status: status.status,
                });
            }
        }
        
        // Count pending reviews from review system
        let pending_reviews = 0u32; // Would query from state.review_system
        
        // Check completion flag
        let completion_flag = agents.iter().all(|a| a.status == "completed");
        
        let output = CheckStatusOutput {
            agents,
            pending_reviews,
            completion_flag,
        };
        
        Ok(json!(output))
    }
}
