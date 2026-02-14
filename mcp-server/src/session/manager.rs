use crate::db::DbPool;
use crate::session::models::AgentStatus;

use anyhow::Result;
use chrono::Utc;
use sqlx::Row;
use tracing::info;

#[derive(Clone)]
pub struct SessionManager {
    pool: DbPool,
}

impl SessionManager {
    pub fn new(pool: DbPool) -> Self {
        Self { pool }
    }

    pub async fn register_agent(&self, agent_id: &str, session_id: &str) -> Result<()> {
        info!("Registering agent {} with session {}", agent_id, session_id);

        let created_at = Utc::now().to_rfc3339();
        sqlx::query(
            "INSERT INTO agents (agent_id, session_id, assigned_files, constraints, status, created_at)
             VALUES (?, ?, '[]', '[]', 'idle', ?)"
        )
        .bind(agent_id)
        .bind(session_id)
        .bind(&created_at)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    pub async fn get_agent_status(&self, agent_id: &str) -> Result<Option<AgentStatus>> {
        let row = sqlx::query("SELECT agent_id, status, created_at FROM agents WHERE agent_id = ?")
            .bind(agent_id)
            .fetch_optional(&self.pool)
            .await?;

        if let Some(row) = row {
            Ok(Some(AgentStatus {
                agent_id: row.get("agent_id"),
                status: row.get("status"),
                last_activity: row.get("created_at"),
            }))
        } else {
            Ok(None)
        }
    }

    pub async fn update_agent_status(&self, agent_id: &str, status: &str) -> Result<()> {
        sqlx::query("UPDATE agents SET status = ? WHERE agent_id = ?")
            .bind(status)
            .bind(agent_id)
            .execute(&self.pool)
            .await?;

        info!("Agent {} status updated to {}", agent_id, status);
        Ok(())
    }

    pub async fn ensure_agent_exists(&self, agent_id: &str) -> Result<()> {
        let created_at = Utc::now().to_rfc3339();
        sqlx::query(
            "INSERT INTO agents (agent_id, session_id, assigned_files, constraints, status, created_at)
             VALUES (?, 'default-session', '[]', '[]', 'idle', ?)
             ON CONFLICT(agent_id) DO NOTHING",
        )
        .bind(agent_id)
        .bind(created_at)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    pub async fn list_agent_statuses(&self) -> Result<Vec<AgentStatus>> {
        let rows = sqlx::query("SELECT agent_id, status, created_at FROM agents ORDER BY agent_id")
            .fetch_all(&self.pool)
            .await?;

        let statuses = rows
            .into_iter()
            .map(|row| AgentStatus {
                agent_id: row.get("agent_id"),
                status: row.get("status"),
                last_activity: row.get("created_at"),
            })
            .collect();

        Ok(statuses)
    }
}
