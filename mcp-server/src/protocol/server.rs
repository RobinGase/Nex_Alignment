use crate::protocol::tools::ToolRegistry;
use crate::AppState;
use anyhow::{anyhow, Result};
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use tokio::io::{AsyncBufReadExt, AsyncRead, AsyncWrite, AsyncWriteExt, BufReader};

#[derive(Clone)]
pub struct McpServer {
    state: AppState,
    tools: ToolRegistry,
    initialized: bool,
}

#[derive(Debug, Serialize, Deserialize)]
struct JsonRpcRequest {
    jsonrpc: String,
    id: Option<Value>,
    method: String,
    params: Option<Value>,
}

#[derive(Debug, Serialize, Deserialize)]
struct JsonRpcResponse {
    jsonrpc: String,
    id: Option<Value>,
    result: Option<Value>,
    error: Option<JsonRpcError>,
}

#[derive(Debug, Serialize, Deserialize)]
struct JsonRpcError {
    code: i32,
    message: String,
    data: Option<Value>,
}

impl McpServer {
    pub fn new(state: AppState) -> Self {
        let tools = ToolRegistry::new();
        Self {
            state,
            tools,
            initialized: false,
        }
    }

    pub async fn start<R, W>(&mut self, stdin: R, mut stdout: W) -> Result<()>
    where
        R: AsyncRead + Unpin,
        W: AsyncWrite + Unpin,
    {
        tracing::info!("MCP Server protocol handler started");

        let mut reader = BufReader::new(stdin);
        loop {
            // Read messages line by line (JSON-RPC over stdio uses newline delimiting)
            let mut line = String::new();

            match reader.read_line(&mut line).await {
                Ok(0) => {
                    tracing::info!("EOF received, shutting down");
                    break;
                }
                Ok(_) => {
                    let line = line.trim();
                    if line.is_empty() {
                        continue;
                    }

                    tracing::debug!("Received: {}", line);

                    // Parse JSON-RPC request
                    match self.handle_request(line).await {
                        Ok(response) => {
                            let response_json = serde_json::to_string(&response)?;
                            let response_with_newline = format!("{}\n", response_json);
                            stdout.write_all(response_with_newline.as_bytes()).await?;
                            stdout.flush().await?;
                            tracing::debug!("Sent response: {}", response_json);
                        }
                        Err(e) => {
                            tracing::error!("Error handling request: {}", e);
                            // Send error response
                            let error_response = JsonRpcResponse {
                                jsonrpc: "2.0".to_string(),
                                id: None,
                                result: None,
                                error: Some(JsonRpcError {
                                    code: -32603,
                                    message: format!("Internal error: {}", e),
                                    data: None,
                                }),
                            };
                            if let Ok(response_json) = serde_json::to_string(&error_response) {
                                let error_with_newline = format!("{}\n", response_json);
                                let _ = stdout.write_all(error_with_newline.as_bytes()).await;
                                let _ = stdout.flush().await;
                            }
                        }
                    }
                }
                Err(e) => {
                    tracing::error!("Error reading from stdin: {}", e);
                    break;
                }
            }
        }

        Ok(())
    }

    async fn handle_request(&mut self, line: &str) -> Result<JsonRpcResponse> {
        let request: JsonRpcRequest = serde_json::from_str(line)?;

        if request.jsonrpc != "2.0" {
            return Ok(JsonRpcResponse {
                jsonrpc: "2.0".to_string(),
                id: request.id,
                result: None,
                error: Some(JsonRpcError {
                    code: -32600,
                    message: "Invalid Request".to_string(),
                    data: None,
                }),
            });
        }

        let result = match request.method.as_str() {
            "initialize" => self.handle_initialize(request.params).await,
            "initialized" => self.handle_initialized().await,
            "shutdown" => self.handle_shutdown().await,
            "tools/list" => self.handle_tools_list(request.params).await,
            "tools/call" => self.handle_tools_call(request.params).await,
            "notifications/cancelled" => self.handle_cancelled(request.params).await,
            _ => Err(anyhow!("Method not found: {}", request.method)),
        };

        match result {
            Ok(value) => Ok(JsonRpcResponse {
                jsonrpc: "2.0".to_string(),
                id: request.id,
                result: Some(value),
                error: None,
            }),
            Err(e) => Ok(JsonRpcResponse {
                jsonrpc: "2.0".to_string(),
                id: request.id,
                result: None,
                error: Some(JsonRpcError {
                    code: -32601,
                    message: format!("Method not found or error: {}", e),
                    data: None,
                }),
            }),
        }
    }

    async fn handle_initialize(&mut self, params: Option<Value>) -> Result<Value> {
        tracing::info!("Received initialize request");

        let capabilities = json!({
            "tools": {},
            "resources": {},
            "prompts": {}
        });

        Ok(json!({
            "protocolVersion": "2024-11-05",
            "capabilities": capabilities,
            "serverInfo": {
                "name": "nap-mcp-server",
                "version": "0.1.0"
            }
        }))
    }

    async fn handle_initialized(&mut self) -> Result<Value> {
        tracing::info!("Received initialized notification");
        self.initialized = true;
        Ok(json!(null))
    }

    async fn handle_shutdown(&mut self) -> Result<Value> {
        tracing::info!("Received shutdown request");
        self.initialized = false;
        Ok(json!(null))
    }

    async fn handle_tools_list(&self, _params: Option<Value>) -> Result<Value> {
        tracing::info!("Received tools/list request");

        let tools = self.tools.list_all();

        Ok(json!({ "tools": tools }))
    }

    async fn handle_tools_call(&mut self, params: Option<Value>) -> Result<Value> {
        tracing::info!("Received tools/call request");

        let params = params.ok_or_else(|| anyhow!("Missing params"))?;
        let tool_name = params["name"]
            .as_str()
            .ok_or_else(|| anyhow!("Missing tool name"))?;

        let arguments = params.get("arguments").cloned().unwrap_or(json!({}));

        let result = self.tools.call(tool_name, arguments, &self.state).await?;

        Ok(json!({
            "content": [
                {
                    "type": "text",
                    "text": serde_json::to_string(&result)?
                }
            ]
        }))
    }

    async fn handle_cancelled(&self, _params: Option<Value>) -> Result<Value> {
        tracing::info!("Received notifications/cancelled");
        Ok(json!(null))
    }
}
