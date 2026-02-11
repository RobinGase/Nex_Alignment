use nap_mcp_server::McpServer;
use anyhow::Result;
use tokio::io;

#[tokio::main]
async fn main() -> Result<()> {
    nap_mcp_server::AppState::init_logging();
    
    let db_url = "sqlite:nap_mcp.db";
    let state = nap_mcp_server::AppState::new(db_url).await?;
    
    tracing::info!("Starting NAP MCP Server...");
    
    let mut stdin = io::stdin();
    let mut stdout = io::stdout();
    
    let mut server = McpServer::new(state);
    
    tracing::info!("NAP MCP Server started successfully, waiting for JSON-RPC messages on stdin/stdout");
    
    server.start(&mut stdin, &mut stdout).await?;
    
    Ok(())
}
