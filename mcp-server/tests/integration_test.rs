use nap_mcp_server::protocol::tools::ToolRegistry;
use nap_mcp_server::AppState;
use serde_json::json;
use sqlx::Row;
use std::env;
use std::sync::OnceLock;
use tempfile::{NamedTempFile, TempDir};
use tokio::sync::Mutex;
use uuid::Uuid;

fn env_lock() -> &'static Mutex<()> {
    static LOCK: OnceLock<Mutex<()>> = OnceLock::new();
    LOCK.get_or_init(|| Mutex::new(()))
}

struct EnvVarGuard {
    key: &'static str,
    old_value: Option<String>,
}

impl EnvVarGuard {
    fn set(key: &'static str, value: &str) -> Self {
        let old_value = env::var(key).ok();
        env::set_var(key, value);
        Self { key, old_value }
    }

    fn unset(key: &'static str) -> Self {
        let old_value = env::var(key).ok();
        env::remove_var(key);
        Self { key, old_value }
    }
}

impl Drop for EnvVarGuard {
    fn drop(&mut self) {
        if let Some(value) = &self.old_value {
            env::set_var(self.key, value);
        } else {
            env::remove_var(self.key);
        }
    }
}

#[tokio::test]
async fn test_four_agent_orchestration_scenario() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());

    let state = AppState::new(&db_url).await.unwrap();

    let session_id = "TEST-SESSION-2026-02-11";
    for idx in 0..4 {
        let agent_id = format!("agent-{}", idx);
        state
            .session_manager
            .register_agent(&agent_id, session_id)
            .await
            .expect("Failed to register agent");
    }

    let statuses = state
        .session_manager
        .list_agent_statuses()
        .await
        .expect("Failed to list statuses");
    assert_eq!(statuses.len(), 4);

    state
        .nap_telemetry
        .emit_event("test_scenario_complete", "4 agents registered")
        .await
        .expect("Failed to emit telemetry event");
}

#[tokio::test]
async fn test_request_review_persists_and_ids_match() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    let state = AppState::new(&db_url).await.unwrap();
    let mut tools = ToolRegistry::new();

    let request_id = format!("req-{}", Uuid::new_v4());

    let response = tools
        .call(
            "request_review",
            json!({
                "work_package": "PKG-001",
                "context": "Review backend patch",
                "requesting_agent": "coding-agent-0",
                "target_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "DevMaster"
                }
            }),
            &state,
        )
        .await
        .expect("request_review call failed");

    let returned_id = response["request_id"]
        .as_str()
        .expect("missing request_id in response");
    assert_eq!(returned_id, request_id);

    let persisted =
        sqlx::query("SELECT request_id, status FROM review_requests WHERE request_id = ?")
            .bind(returned_id)
            .fetch_optional(&state.db_pool)
            .await
            .expect("db query failed")
            .expect("request was not persisted");

    let persisted_id: String = persisted.get("request_id");
    let status: String = persisted.get("status");
    assert_eq!(persisted_id, returned_id);
    assert_eq!(status, "pending");
}

#[tokio::test]
async fn test_submit_review_updates_status_correctly() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    let state = AppState::new(&db_url).await.unwrap();
    let mut tools = ToolRegistry::new();

    let request_id = format!("req-{}", Uuid::new_v4());
    tools
        .call(
            "request_review",
            json!({
                "work_package": "PKG-002",
                "context": "Review API change",
                "requesting_agent": "coding-agent-0",
                "target_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "DevMaster"
                }
            }),
            &state,
        )
        .await
        .expect("failed to seed review request");

    let submit_response = tools
        .call(
            "submit_review",
            json!({
                "request_id": request_id,
                "findings": "Looks good",
                "decision": "approved",
                "reviewing_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "ReviewLane"
                }
            }),
            &state,
        )
        .await
        .expect("submit_review failed");

    assert_eq!(submit_response["success"], json!(true));
    assert_eq!(submit_response["request_status"], json!("completed"));

    let request_row = sqlx::query("SELECT status FROM review_requests WHERE request_id = ?")
        .bind(&request_id)
        .fetch_one(&state.db_pool)
        .await
        .expect("failed to load review request row");
    let request_status: String = request_row.get("status");
    assert_eq!(request_status, "completed");

    let response_row = sqlx::query(
        "SELECT request_id, approval_decision FROM review_responses WHERE request_id = ?",
    )
    .bind(&request_id)
    .fetch_one(&state.db_pool)
    .await
    .expect("failed to load review response row");

    let response_request_id: String = response_row.get("request_id");
    let approval_decision: String = response_row.get("approval_decision");
    assert_eq!(response_request_id, request_id);
    assert_eq!(approval_decision, "approved");
}

#[tokio::test]
async fn test_check_status_returns_db_driven_counts() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    let state = AppState::new(&db_url).await.unwrap();
    let mut tools = ToolRegistry::new();

    state
        .session_manager
        .register_agent("agent-a", "session-a")
        .await
        .expect("failed to register agent-a");
    state
        .session_manager
        .register_agent("agent-b", "session-a")
        .await
        .expect("failed to register agent-b");

    let request_id = format!("req-{}", Uuid::new_v4());
    tools
        .call(
            "request_review",
            json!({
                "work_package": "PKG-003",
                "context": "Review status count",
                "requesting_agent": "coding-agent-0",
                "target_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "DevMaster"
                }
            }),
            &state,
        )
        .await
        .expect("failed to create pending review");

    let status = tools
        .call("check_status", json!({}), &state)
        .await
        .expect("check_status failed");

    let pending_reviews = status["pending_reviews"]
        .as_u64()
        .expect("pending_reviews should be numeric");
    let agents = status["agents"]
        .as_array()
        .expect("agents should be an array");

    assert_eq!(pending_reviews, 1);
    assert_eq!(agents.len(), 4); // 2 registered + 2 ensured by request_review
}

#[tokio::test]
async fn test_lane_mismatch_is_rejected() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    let state = AppState::new(&db_url).await.unwrap();
    let mut tools = ToolRegistry::new();

    let request_id = format!("req-{}", Uuid::new_v4());
    tools
        .call(
            "request_review",
            json!({
                "work_package": "PKG-004",
                "context": "Lane mismatch test",
                "requesting_agent": "coding-agent-0",
                "target_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "DevMaster"
                }
            }),
            &state,
        )
        .await
        .expect("failed to seed review request");

    let result = tools
        .call(
            "submit_review",
            json!({
                "request_id": request_id,
                "findings": "should fail",
                "decision": "approved",
                "reviewing_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "DevMaster"
                }
            }),
            &state,
        )
        .await;

    assert!(result.is_err());
    let message = format!("{}", result.err().unwrap());
    assert!(message.contains("out-of-lane execution rejected"));
}

#[tokio::test]
async fn test_submit_review_actor_mismatch_rejected() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    let state = AppState::new(&db_url).await.unwrap();
    let mut tools = ToolRegistry::new();

    let request_id = format!("req-{}", Uuid::new_v4());
    tools
        .call(
            "request_review",
            json!({
                "work_package": "PKG-005",
                "context": "actor mismatch test",
                "requesting_agent": "coding-agent-0",
                "target_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "DevMaster"
                }
            }),
            &state,
        )
        .await
        .expect("failed to seed review request");

    let result = tools
        .call(
            "submit_review",
            json!({
                "request_id": request_id,
                "findings": "spoofed actor",
                "decision": "approved",
                "reviewing_agent": "frontend-subagent-0",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "FrontEndTestBranch"
                }
            }),
            &state,
        )
        .await;

    assert!(result.is_err());
    let message = format!("{}", result.err().unwrap());
    assert!(message.contains("does not match request target_agent"));
}

#[tokio::test]
async fn test_submit_review_conditional_approval_maps_to_conditional() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    let state = AppState::new(&db_url).await.unwrap();
    let mut tools = ToolRegistry::new();

    let request_id = format!("req-{}", Uuid::new_v4());
    tools
        .call(
            "request_review",
            json!({
                "work_package": "PKG-006",
                "context": "conditional approval mapping",
                "requesting_agent": "coding-agent-0",
                "target_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "DevMaster"
                }
            }),
            &state,
        )
        .await
        .expect("failed to seed review request");

    let response = tools
        .call(
            "submit_review",
            json!({
                "request_id": request_id,
                "findings": "acceptable with conditions",
                "decision": "conditional_approval",
                "reviewing_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "ReviewLane"
                }
            }),
            &state,
        )
        .await
        .expect("submit_review failed");

    assert_eq!(response["request_status"], json!("completed"));

    let request_row = sqlx::query("SELECT status FROM review_requests WHERE request_id = ?")
        .bind(&request_id)
        .fetch_one(&state.db_pool)
        .await
        .expect("failed to fetch request status");
    let status: String = request_row.get("status");
    assert_eq!(status, "completed");

    let response_row =
        sqlx::query("SELECT approval_decision FROM review_responses WHERE request_id = ?")
            .bind(&request_id)
            .fetch_one(&state.db_pool)
            .await
            .expect("failed to fetch approval decision");
    let approval_decision: String = response_row.get("approval_decision");
    assert_eq!(approval_decision, "conditional");
}

#[tokio::test]
async fn test_request_review_missing_ack_rejected() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    let state = AppState::new(&db_url).await.unwrap();
    let mut tools = ToolRegistry::new();

    let result = tools
        .call(
            "request_review",
            json!({
                "work_package": "PKG-007",
                "context": "ack required",
                "requesting_agent": "coding-agent-0",
                "target_agent": "review-agent-1"
            }),
            &state,
        )
        .await;

    assert!(result.is_err());
    let message = format!("{}", result.err().unwrap());
    assert!(message.contains("ack is required in lane-enforced mode"));
}

#[tokio::test]
async fn test_submit_review_missing_ack_rejected() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    let state = AppState::new(&db_url).await.unwrap();
    let mut tools = ToolRegistry::new();

    let request_id = format!("req-{}", Uuid::new_v4());
    tools
        .call(
            "request_review",
            json!({
                "work_package": "PKG-008",
                "context": "seed for missing ack",
                "requesting_agent": "coding-agent-0",
                "target_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "DevMaster"
                }
            }),
            &state,
        )
        .await
        .expect("failed to seed review request");

    let result = tools
        .call(
            "submit_review",
            json!({
                "request_id": request_id,
                "findings": "missing ack should fail",
                "decision": "approved",
                "reviewing_agent": "review-agent-1"
            }),
            &state,
        )
        .await;

    assert!(result.is_err());
    let message = format!("{}", result.err().unwrap());
    assert!(message.contains("ack is required in lane-enforced mode"));
}

#[tokio::test]
async fn test_request_review_ack_target_mismatch_rejected() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    let state = AppState::new(&db_url).await.unwrap();
    let mut tools = ToolRegistry::new();

    let request_id = format!("req-{}", Uuid::new_v4());
    let result = tools
        .call(
            "request_review",
            json!({
                "work_package": "PKG-009",
                "context": "target mismatch",
                "requesting_agent": "coding-agent-0",
                "target_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "frontend-subagent-0",
                    "branch": "DevMaster"
                }
            }),
            &state,
        )
        .await;

    assert!(result.is_err());
    let message = format!("{}", result.err().unwrap());
    assert!(message.contains("lane mismatch: ack.target_agent"));
}

#[tokio::test]
async fn test_submit_review_ack_target_mismatch_rejected() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    let state = AppState::new(&db_url).await.unwrap();
    let mut tools = ToolRegistry::new();

    let request_id = format!("req-{}", Uuid::new_v4());
    tools
        .call(
            "request_review",
            json!({
                "work_package": "PKG-010",
                "context": "seed for target mismatch",
                "requesting_agent": "coding-agent-0",
                "target_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "DevMaster"
                }
            }),
            &state,
        )
        .await
        .expect("failed to seed review request");

    let result = tools
        .call(
            "submit_review",
            json!({
                "request_id": request_id,
                "findings": "wrong target ack",
                "decision": "approved",
                "reviewing_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "frontend-subagent-0",
                    "branch": "ReviewLane"
                }
            }),
            &state,
        )
        .await;

    assert!(result.is_err());
    let message = format!("{}", result.err().unwrap());
    assert!(message.contains("lane mismatch: ack.target_agent"));
}

#[tokio::test]
async fn test_submit_review_rejects_completed_request_resubmission() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    let state = AppState::new(&db_url).await.unwrap();
    let mut tools = ToolRegistry::new();

    let request_id = format!("req-{}", Uuid::new_v4());
    tools
        .call(
            "request_review",
            json!({
                "work_package": "PKG-011",
                "context": "resubmission guard",
                "requesting_agent": "coding-agent-0",
                "target_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "DevMaster"
                }
            }),
            &state,
        )
        .await
        .expect("failed to seed review request");

    tools
        .call(
            "submit_review",
            json!({
                "request_id": request_id,
                "findings": "first submit",
                "decision": "approved",
                "reviewing_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "ReviewLane"
                }
            }),
            &state,
        )
        .await
        .expect("first submit should succeed");

    let result = tools
        .call(
            "submit_review",
            json!({
                "request_id": request_id,
                "findings": "second submit should fail",
                "decision": "approved",
                "reviewing_agent": "review-agent-1",
                "ack": {
                    "request_id": request_id,
                    "target_agent": "review-agent-1",
                    "branch": "ReviewLane"
                }
            }),
            &state,
        )
        .await;

    assert!(result.is_err());
    let message = format!("{}", result.err().unwrap());
    assert!(message.contains("is not pending"));
}

#[tokio::test]
async fn test_tools_list_uses_input_schema_camel_case() {
    let tools = ToolRegistry::new();
    let value =
        serde_json::to_value(tools.list_all()).expect("failed to serialize tool definitions");
    let first = value
        .as_array()
        .and_then(|items| items.first())
        .expect("expected at least one tool definition");

    assert!(first.get("inputSchema").is_some());
    assert!(first.get("input_schema").is_none());
}

#[tokio::test]
async fn test_read_assignments_plans_dir_override_and_ambiguity() {
    let _guard = env_lock().lock().await;

    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    let state = AppState::new(&db_url).await.unwrap();
    let mut tools = ToolRegistry::new();

    let plans_dir = TempDir::new().unwrap();
    let plan_a = plans_dir.path().join("a.yaml");
    let plan_b = plans_dir.path().join("b.yaml");

    std::fs::write(
        &plan_a,
        r#"plan_id: "PLAN-A"
assignees:
  - agent_id: "agent-a"
    files:
      - "src/a/*"
    constraints:
      - "c-a"
"#,
    )
    .unwrap();

    std::fs::write(
        &plan_b,
        r#"plan_id: "PLAN-B"
assignees:
  - agent_id: "agent-b"
    files:
      - "src/b/*"
    constraints:
      - "c-b"
"#,
    )
    .unwrap();

    let _plans_dir = EnvVarGuard::set(
        "NAP_MCP_PLANS_DIR",
        plans_dir.path().to_string_lossy().as_ref(),
    );
    let _plans_path = EnvVarGuard::unset("NAP_MCP_PLANS_PATH");

    let ambiguous = tools.call("read_assignments", json!({}), &state).await;
    assert!(ambiguous.is_err());
    let message = format!("{}", ambiguous.err().unwrap());
    assert!(message.contains("specify plan_id to disambiguate"));

    let selected = tools
        .call("read_assignments", json!({ "plan_id": "PLAN-B" }), &state)
        .await
        .expect("read_assignments with explicit plan_id should succeed");

    assert_eq!(selected["plan_id"], json!("PLAN-B"));
    let assignments = selected["assignments"].as_array().unwrap();
    assert_eq!(assignments.len(), 1);
    assert_eq!(assignments[0]["agent_id"], json!("agent-b"));
}

#[tokio::test]
async fn test_read_assignments_plans_path_override_single_file() {
    let _guard = env_lock().lock().await;

    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    let state = AppState::new(&db_url).await.unwrap();
    let mut tools = ToolRegistry::new();

    let plans_dir = TempDir::new().unwrap();
    let plan_path = plans_dir.path().join("single.yaml");

    std::fs::write(
        &plan_path,
        r#"plan_id: "PLAN-SINGLE"
assignees:
  - agent_id: "agent-single"
    files:
      - "src/single/*"
    constraints:
      - "c-single"
"#,
    )
    .unwrap();

    let _plans_path = EnvVarGuard::set("NAP_MCP_PLANS_PATH", plan_path.to_string_lossy().as_ref());
    let _plans_dir = EnvVarGuard::unset("NAP_MCP_PLANS_DIR");

    let response = tools
        .call("read_assignments", json!({}), &state)
        .await
        .expect("read_assignments from NAP_MCP_PLANS_PATH should succeed");

    assert_eq!(response["plan_id"], json!("PLAN-SINGLE"));
}
