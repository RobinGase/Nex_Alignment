use crate::db::DbPool;
use anyhow::Result;

#[derive(Clone)]
pub struct PlanDispatcher {
    pool: DbPool,
}

impl PlanDispatcher {
    pub fn new(pool: DbPool) -> Self {
        Self { pool }
    }
}
