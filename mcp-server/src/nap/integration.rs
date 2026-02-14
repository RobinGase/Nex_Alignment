use crate::db::DbPool;
use anyhow::Result;
use uuid::Uuid;

#[derive(Clone)]
pub struct NapTelemetry {
    pool: DbPool,
}

impl NapTelemetry {
    pub fn new(pool: DbPool) -> Self {
        Self { pool }
    }

    pub async fn emit_event(&self, event_type: &str, description: &str) -> Result<()> {
        let event_id = Uuid::new_v4().to_string();
        Ok(())
    }
}
