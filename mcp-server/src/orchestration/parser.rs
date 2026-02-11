use anyhow::Result;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct TaskPlan {
    pub plan_id: String,
    pub assignees: Vec<Assignee>,
}

#[derive(Debug, Deserialize)]
pub struct Assignee {
    pub agent_id: String,
    pub files: Vec<String>,
}

pub fn parse_plan(content: &str) -> Result<TaskPlan> {
    Ok(serde_yaml::from_str(content)?)
}
