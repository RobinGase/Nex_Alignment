use crate::db::DbPool;
use anyhow::Result;
use uuid::Uuid;

#[derive(Clone)]
pub struct ReviewSystem {
    pool: DbPool,
}

impl ReviewSystem {
    pub fn new(pool: DbPool) -> Self {
        Self { pool }
    }
    
    pub async fn create_review_request(&self, requesting_agent: String, target_agent: String) -> Result<String> {
        let request_id = Uuid::new_v4().to_string();
        Ok(request_id)
    }
}
