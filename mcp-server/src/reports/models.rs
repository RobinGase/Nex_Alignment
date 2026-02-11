use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Report {
    pub report_id: String,
    pub agent_id: String,
    pub report_type: String,
    pub content: serde_json::Value,
}
