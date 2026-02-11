use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReviewRequest {
    pub request_id: String,
    pub requesting_agent: String,
    pub target_agent: String,
    pub work_package_id: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReviewResponse {
    pub response_id: String,
    pub request_id: String,
    pub reviewing_agent: String,
}
