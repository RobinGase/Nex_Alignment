use anyhow::{anyhow, Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentDefinitionCatalog {
    pub version: String,
    pub agents: Vec<AgentDefinition>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentDefinition {
    pub id: String,
    pub codename: String,
    pub role: String,
    pub lane: AgentLane,
    pub scopes: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentLane {
    pub branch: String,
}

#[derive(Debug, Clone)]
pub struct AgentDefinitions {
    catalog: AgentDefinitionCatalog,
    by_id: HashMap<String, AgentDefinition>,
    single_agent_fallback: bool,
}

impl AgentDefinitions {
    pub fn load_from_startup() -> Result<Self> {
        let explicit_path = std::env::var("NAP_MCP_AGENT_DEFINITIONS_PATH").ok();
        let config_path = explicit_path.map(PathBuf::from).unwrap_or_else(|| {
            PathBuf::from(env!("CARGO_MANIFEST_DIR"))
                .join("config")
                .join("agent_definitions.yaml")
        });

        let single_agent_fallback = env_flag("NAP_MCP_SINGLE_AGENT");

        if !config_path.exists() {
            if single_agent_fallback {
                return Ok(Self::single_agent_mode());
            }
            return Err(anyhow!(
                "agent definition file not found at {}. Set NAP_MCP_SINGLE_AGENT=1 to allow fallback mode",
                config_path.display()
            ));
        }

        Self::load_from_path(&config_path, single_agent_fallback)
    }

    pub fn load_from_path(path: &Path, single_agent_fallback: bool) -> Result<Self> {
        let raw = fs::read_to_string(path)
            .with_context(|| format!("failed reading agent definitions at {}", path.display()))?;

        let catalog: AgentDefinitionCatalog = serde_yaml::from_str(&raw).with_context(|| {
            format!(
                "failed parsing agent definitions yaml at {}",
                path.display()
            )
        })?;

        let definitions = Self::from_catalog(catalog, single_agent_fallback)?;
        Ok(definitions)
    }

    pub fn from_catalog(
        catalog: AgentDefinitionCatalog,
        single_agent_fallback: bool,
    ) -> Result<Self> {
        validate_catalog(&catalog, single_agent_fallback)?;

        let mut by_id = HashMap::new();
        for agent in &catalog.agents {
            by_id.insert(agent.id.clone(), agent.clone());
        }

        Ok(Self {
            catalog,
            by_id,
            single_agent_fallback,
        })
    }

    pub fn single_agent_mode() -> Self {
        Self {
            catalog: AgentDefinitionCatalog {
                version: "fallback".to_string(),
                agents: vec![],
            },
            by_id: HashMap::new(),
            single_agent_fallback: true,
        }
    }

    pub fn is_single_agent_fallback(&self) -> bool {
        self.single_agent_fallback
    }

    pub fn has_agent(&self, agent_id: &str) -> bool {
        self.by_id.contains_key(agent_id)
    }

    pub fn get_agent(&self, agent_id: &str) -> Option<&AgentDefinition> {
        self.by_id.get(agent_id)
    }

    pub fn branch_for_agent(&self, agent_id: &str) -> Option<&str> {
        self.get_agent(agent_id)
            .map(|agent| agent.lane.branch.as_str())
    }

    pub fn all_agents(&self) -> &[AgentDefinition] {
        &self.catalog.agents
    }
}

fn validate_catalog(catalog: &AgentDefinitionCatalog, single_agent_fallback: bool) -> Result<()> {
    if catalog.version.trim().is_empty() {
        return Err(anyhow!("agent definition version is required"));
    }

    if catalog.agents.is_empty() {
        if single_agent_fallback {
            return Ok(());
        }
        return Err(anyhow!("agent definitions must include at least one agent"));
    }

    let mut seen_ids = HashMap::new();
    for agent in &catalog.agents {
        if agent.id.trim().is_empty() {
            return Err(anyhow!("agent id cannot be empty"));
        }
        if agent.codename.trim().is_empty() {
            return Err(anyhow!(
                "agent codename cannot be empty for agent {}",
                agent.id
            ));
        }
        if agent.role.trim().is_empty() {
            return Err(anyhow!("agent role cannot be empty for agent {}", agent.id));
        }
        if agent.lane.branch.trim().is_empty() {
            return Err(anyhow!(
                "lane.branch cannot be empty for agent {}",
                agent.id
            ));
        }
        if agent.scopes.is_empty() {
            return Err(anyhow!("scopes cannot be empty for agent {}", agent.id));
        }

        for scope in &agent.scopes {
            if scope.trim().is_empty() {
                return Err(anyhow!("scope cannot be empty for agent {}", agent.id));
            }
        }

        if seen_ids.insert(agent.id.clone(), true).is_some() {
            return Err(anyhow!("duplicate agent id found: {}", agent.id));
        }
    }

    if !single_agent_fallback {
        let required = ["coding-agent-0", "frontend-subagent-0", "review-agent-1"];
        for required_id in required {
            if !catalog.agents.iter().any(|agent| agent.id == required_id) {
                return Err(anyhow!(
                    "required agent definition missing: {}",
                    required_id
                ));
            }
        }
    }

    Ok(())
}

fn env_flag(name: &str) -> bool {
    match std::env::var(name) {
        Ok(value) => {
            let normalized = value.trim().to_ascii_lowercase();
            normalized == "1" || normalized == "true" || normalized == "yes" || normalized == "on"
        }
        Err(_) => false,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn validates_required_agent_ids() {
        let catalog = AgentDefinitionCatalog {
            version: "1".to_string(),
            agents: vec![AgentDefinition {
                id: "coding-agent-0".to_string(),
                codename: "DevMaster".to_string(),
                role: "coding".to_string(),
                lane: AgentLane {
                    branch: "DevMaster".to_string(),
                },
                scopes: vec!["backend/**".to_string()],
            }],
        };

        let result = AgentDefinitions::from_catalog(catalog, false);
        assert!(result.is_err());
    }
}
