use crate::AppState;
use anyhow::Result;
use tokio::io::{AsyncRead, AsyncWrite};

#[derive(Clone)]
pub struct McpServer {
    state: AppState,
}

impl McpServer {
    pub fn new(state: AppState) -> Self {
        Self { state }
    }
    
    pub async fn start<R, W>(&self, mut stdin: R, mut stdout: W) -> Result<()>
    where
        R: AsyncRead + Unpin,
        W: AsyncWrite + Unpin,
    {
        tokio::io::copy(&mut stdin, &mut stdout).await?;
        Ok(())
    }
}
