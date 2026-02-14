pub mod config;
pub mod db;
pub mod nap;
pub mod orchestration;
pub mod protocol;
pub mod reports;
pub mod review;
pub mod session;

pub use config::agent_definitions::AgentDefinitions;
pub use db::{connection::DbPool, queries::DbQueries};
pub use nap::integration::NapTelemetry;
pub use orchestration::dispatcher::PlanDispatcher;
pub use protocol::server::McpServer;
pub use reports::repository::ReportRepository;
pub use review::system::ReviewSystem;
pub use session::manager::SessionManager;
pub use session::models::Agent;

use anyhow::Result;
use tracing_subscriber::{fmt, EnvFilter};

#[derive(Clone)]
pub struct AppState {
    pub db_pool: DbPool,
    pub agent_definitions: AgentDefinitions,
    pub session_manager: SessionManager,
    pub review_system: ReviewSystem,
    pub report_repository: ReportRepository,
    pub plan_dispatcher: PlanDispatcher,
    pub nap_telemetry: NapTelemetry,
}

impl AppState {
    pub async fn new(database_url: &str) -> Result<Self> {
        let db_pool = db::connection::create_pool(database_url).await?;
        let agent_definitions = config::agent_definitions::AgentDefinitions::load_from_startup()?;

        let session_manager = SessionManager::new(db_pool.clone());
        let review_system = ReviewSystem::new(db_pool.clone());
        let report_repository = ReportRepository::new(db_pool.clone());
        let plan_dispatcher = PlanDispatcher::new(db_pool.clone());
        let nap_telemetry = NapTelemetry::new(db_pool.clone());

        Ok(Self {
            db_pool,
            agent_definitions,
            session_manager,
            review_system,
            report_repository,
            plan_dispatcher,
            nap_telemetry,
        })
    }

    pub fn init_logging() {
        let filter = EnvFilter::from_default_env().add_directive(tracing::Level::INFO.into());

        fmt().with_env_filter(filter).pretty().init();
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_app_state_creation() {
        let pool = tempfile::NamedTempFile::new().unwrap();
        let db_url = format!("sqlite:{}", pool.path().display());

        let state = AppState::new(&db_url).await;
        assert!(state.is_ok());
    }
}
