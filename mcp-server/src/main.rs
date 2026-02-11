use nap_mcp_server::AppState;
use anyhow::Result;

#[tokio::main]
async fn main() -> Result<()> {
    AppState::init_logging();
    
    let db_url = "sqlite:nap_mcp.db";
    let _state = AppState::new(db_url).await?;
    
    println!("NAP MCP Server started successfully");
    
    Ok(())
}
