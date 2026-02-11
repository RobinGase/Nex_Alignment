use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct ReadAssignmentsRequest {
    pub plan_id: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ReadAssignmentsResponse {
    pub plan_id: String,
    pub assignments: Vec<AgentAssignment>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct AgentAssignment {
    pub agent_id: String,
    pub files: Vec<String>,
    pub constraints: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct RequestReviewInput {
    pub work_package: String,
    pub context: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct RequestReviewResponse {
    pub request_id: String,
    pub deadline: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SubmitReviewInput {
    pub request_id: String,
    pub findings: String,
    pub decision: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CheckStatusResponse {
    pub agents: Vec<AgentStatus>,
    pub pending_reviews: u32,
    pub completion_flag: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct AgentStatus {
    pub agent_id: String,
    pub status: String,
}
