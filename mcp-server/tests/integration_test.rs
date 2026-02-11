use nap_mcp_server::AppState;
use sqlx::SqlitePool;
use tempfile::NamedTempFile;

#[tokio::test]
async fn test_four_agent_orchestration_scenario() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    
    let state = AppState::new(&db_url).await.unwrap();
    
    let session_id = "TEST-SESSION-2026-02-11";
    
    state
        .session_manager
        .register_agent("agent-0", session_id)
        .await
        .expect("Failed to register agent-0");
    
    state
        .session_manager
        .register_agent("agent-1", session_id)
        .await
        .expect("Failed to register agent-1");
    
    state
        .session_manager
        .register_agent("agent-2", session_id)
        .await
        .expect("Failed to register agent-2");
    
    state
        .session_manager
        .register_agent("agent-3", session_id)
        .await
        .expect("Failed to register agent-3");
    
    let status_0 = state
        .session_manager
        .get_agent_status("agent-0")
        .await
        .expect("Failed to get agent-0 status");
    
    assert!(status_0.is_some());
    assert_eq!(status_0.unwrap().status, "idle");
    
    state
        .nap_telemetry
        .emit_event("test_scenario_complete", "4 agents registered")
        .await
        .expect("Failed to emit telemetry event");
}

#[tokio::test]
async fn test_review_request_flow() {
    let db_file = NamedTempFile::new().unwrap();
    let db_url = format!("sqlite:{}", db_file.path().display());
    
    let state = AppState::new(&db_url).await.unwrap();
    
    let session_id = "TEST-SESSION-REVIEW";
    
    state
        .session_manager
        .register_agent("reviewer", session_id)
        .await
        .expect("Failed to register reviewer");
    
    let request_id = state
        .review_system
        .create_review_request(
            "agent-0".to_string(),
            "reviewer".to_string(),
        )
        .await
        .expect("Failed to create review request");
    
    assert_eq!(request_id.len(), 36);
}
