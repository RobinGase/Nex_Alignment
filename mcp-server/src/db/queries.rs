use serde_json::Value;
use sqlx::{Row, SqlitePool};

use anyhow::{Context, Result};
use chrono::Utc;

#[derive(Clone)]
pub struct DbQueries {
    pub pool: SqlitePool,
}

impl DbQueries {
    pub fn new(pool: SqlitePool) -> Self {
        Self { pool }
    }

    pub async fn insert_agent(&self, agent_id: &str, session_id: &str) -> Result<()> {
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
}
