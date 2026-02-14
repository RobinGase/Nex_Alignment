use anyhow::Result;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct TaskPlan {
    pub plan_id: String,
    pub orchestrator: Option<String>,
    pub risk_class: Option<i32>,
    pub autonomy_tier: Option<String>,
    pub assignees: Vec<Assignee>,
}

#[derive(Debug, Deserialize)]
pub struct Assignee {
    pub agent_id: String,
    pub files: Vec<String>,
    #[serde(default)]
    pub constraints: Vec<String>,
    #[serde(default)]
    pub dependencies: Vec<String>,
}

pub fn parse_plan(content: &str) -> Result<TaskPlan> {
    Ok(serde_yaml::from_str(content)?)
}
