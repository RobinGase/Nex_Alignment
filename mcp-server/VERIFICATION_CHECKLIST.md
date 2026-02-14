# MCP Verification Checklist (CLI/IDE)

This checklist validates client compatibility, DB persistence, lane enforcement, plan routing, and fallback behavior.

## 0) Build + quality gates

```bash
cargo fmt
cargo clippy --all-targets
cargo test
cargo test --test integration_test -- --nocapture
```

Expected:
- `cargo fmt` exits clean.
- `cargo clippy` may show pre-existing warnings, but no hard failures unless configured.
- All tests pass.

---

## 1) JSON-RPC initialize + tools/list (verify `inputSchema`)

PowerShell examples:

```powershell
# from mcp-server/
$init = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"cli-smoke","version":"1.0"}}}'
$init | cargo run

$tools = '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
$resp = $tools | cargo run
$parsed = $resp | ConvertFrom-Json
$parsed.result.tools[0].PSObject.Properties.Name
```

Expected:
- `initialize` returns `protocolVersion`, `capabilities`, `serverInfo`.
- `tools/list` returns tools with `inputSchema` (camelCase).
- `input_schema` should not appear in the serialized MCP tool definitions.

---

## 2) check_status is DB-driven

```powershell
$check = '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"check_status","arguments":{}}}'
$check | cargo run
```

Expected:
- Response contains `agents` array and numeric `pending_reviews`.
- Values come from SQLite state, not hardcoded constants.

---

## 3) request_review -> submit_review persistence

### 3.1 request_review

```powershell
$reqId = "req-cli-001"
$requestReview = @"
{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"request_review","arguments":{"work_package":"PKG-CLI-1","context":"cli persistence check","requesting_agent":"coding-agent-0","target_agent":"review-agent-1","ack":{"request_id":"$reqId","target_agent":"review-agent-1","branch":"DevMaster"}}}}
"@
$requestReview | cargo run
```

Expected:
- Response `request_id` equals `req-cli-001`.
- Row exists in `review_requests` with `status='pending'`.

### 3.2 submit_review

```powershell
$submitReview = @"
{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"submit_review","arguments":{"request_id":"$reqId","findings":"looks good","decision":"conditional_approval","reviewing_agent":"review-agent-1","ack":{"request_id":"$reqId","target_agent":"review-agent-1","branch":"ReviewLane"}}}}
"@
$submitReview | cargo run
```

Expected:
- Response shows `review_submitted=true` and `request_status="completed"`.
- `review_requests.status` becomes `completed`.
- `review_responses.approval_decision` stored as `conditional`.

### 3.3 verify rows in SQLite

If `sqlite3` CLI is available:

```bash
sqlite3 nap_mcp.db "SELECT request_id,status FROM review_requests WHERE request_id='req-cli-001';"
sqlite3 nap_mcp.db "SELECT request_id,approval_decision FROM review_responses WHERE request_id='req-cli-001';"
```

Expected:
- `review_requests`: `req-cli-001|completed`
- `review_responses`: `req-cli-001|conditional`

---

## 4) read_assignments ambiguity behavior

### 4.1 multiple plans + no plan_id -> reject

```powershell
$readAssignments = '{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"read_assignments","arguments":{}}}'
$readAssignments | cargo run
```

Expected (when multiple plan files present):
- Error includes: `multiple plan files found; specify plan_id to disambiguate`.

### 4.2 explicit plan_id -> success

```powershell
$readAssignmentsById = '{"jsonrpc":"2.0","id":7,"method":"tools/call","params":{"name":"read_assignments","arguments":{"plan_id":"SESSION-2026-02-11"}}}'
$readAssignmentsById | cargo run
```

Expected:
- Returns assignments for specified plan.

---

## 5) Packaged binary overrides (agent definitions + plans)

```powershell
# Override agent definition catalog
$env:NAP_MCP_AGENT_DEFINITIONS_PATH = "C:\deploy\config\agent_definitions.yaml"

# Override plan source (directory)
$env:NAP_MCP_PLANS_DIR = "C:\deploy\plans"

# or explicit single plan file
$env:NAP_MCP_PLANS_PATH = "C:\deploy\plans\session.yaml"

.\target\release\nap-mcp-server.exe
```

Expected:
- Startup succeeds using provided paths.
- No dependency on source-tree location.

---

## 6) Single-agent fallback mode

```powershell
$env:NAP_MCP_SINGLE_AGENT = "1"
Remove-Item Env:NAP_MCP_AGENT_DEFINITIONS_PATH -ErrorAction SilentlyContinue

# (optional) point to empty/missing definitions to prove fallback
$env:NAP_MCP_AGENT_DEFINITIONS_PATH = "C:\missing\agent_definitions.yaml"

$check = '{"jsonrpc":"2.0","id":8,"method":"tools/call","params":{"name":"check_status","arguments":{}}}'
$check | cargo run
```

Expected:
- Server starts in fallback mode (warning logged).
- Lane checks are relaxed; ACK requirement is bypassed in fallback mode.

---

## 7) Lane enforcement negative checks

- Missing ACK for `request_review`/`submit_review` in lane mode -> rejected with:
  - `ack is required in lane-enforced mode (request_id, target_agent, branch)`
- Wrong branch for actor -> rejected with:
  - `out-of-lane execution rejected: ...`
- Spoofed reviewer (`reviewing_agent != persisted target_agent`) -> rejected.

