# NAP MCP Server

Model Context Protocol (MCP) server for secure multi-agent collaboration within the NexGentic Agents Protocol (NAP).

## Overview

This MCP server enables:
- Secure agent session management and isolation
- Review request/response cycles between agents
- Task distribution from orchestrator to multiple agents
- Report aggregation and status tracking
- NAP compliance validation and telemetry emission

## Features

- **Agent Isolation**: Each agent works within strict interaction contracts
- **Review System**: Structured feedback loops with findings and approvals
- **File-Based Plans**: Low-token-cost task distribution via YAML configuration
- **SQLite Persistence**: Reliable storage for all reviews, reports, and telemetry
- **NAP Integration**: Compliance checks and telemetry emission

## Installation

### Prerequisites

- Rust 2021 edition
- Cargo package manager
- SQLite3

### Build

```bash
cd mcp-server
cargo build --release
```

### Run

```bash
cargo run
```

## Usage

### 1. Create a Task Distribution Plan

Create a YAML file in the `plans/` directory:

```yaml
# plans/session-2026-02-11.yaml
plan_id: "SESSION-2026-02-11"
created_at: "2026-02-11T10:00:00Z"
orchestrator: "orchestrator-session-id"
risk_class: 2
autonomy_tier: "A2"

interaction_contract:
  isolation_level: "strict"
  communication: "via_mcp_only"
  forbidden: ["modify_other_agent_files", "direct_agent_communication"]

assignees:
  - agent_id: "agent-session-0"
    files:
      - "src/module_a/*"
      - "tests/module_a/*"
    constraints:
      - "no_modify_files_starting_with_B"
    dependencies: []
    
  - agent_id: "agent-session-1"
    files:
      - "src/module_b/*"
    constraints:
      - "only_read_module_a"
    dependencies: ["agent-session-0"]
```

### 2. MCP Tools

The server exposes the following MCP tools:

#### `read_assignments(plan_id)`
**Input**: Plan ID string (required when multiple plan files exist)  
**Output**: Agent assignments with files and constraints loaded from `plans/*.yaml`

#### `request_review(work_package, context)`
**Input**: Work package ID, context, `requesting_agent`, `target_agent`, and `ack` (`request_id`, `target_agent`, `branch`)  
**Output**: Review request ID and deadline

#### `submit_review(request_id, findings, decision)`
**Input**: Request ID, findings, decision, `reviewing_agent`, and `ack` (`request_id`, `target_agent`, `branch`)  
**Output**: Confirmation ID

#### `check_status()`
**Input**: None  
**Output**: Agent statuses, pending reviews, completion flag

### 3. Agent Definitions and Lane Enforcement

The MCP server loads lane definitions from `config/agent_definitions.yaml` during startup and validates:
- unique agent IDs
- required IDs (`coding-agent-0`, `frontend-subagent-0`, `review-agent-1`)
- non-empty branch lanes and scopes

Definition format:

```yaml
version: "1"
agents:
  - id: "coding-agent-0"
    codename: "DevMaster"
    role: "backend_coding"
    lane:
      branch: "DevMaster"
    scopes:
      - "backend/**"
      - "artifacts/**"
```

Lane guardrails are enforced in normal mode:
- `ack.request_id`
- `ack.target_agent`
- `ack.branch`

`ack.branch` must match the **actor agent lane branch**:
- `request_review`: branch must match `requesting_agent` lane
- `submit_review`: branch must match `reviewing_agent` lane and `reviewing_agent` must equal persisted request `target_agent`

Out-of-lane calls are rejected.

### 4. Single-Agent Fallback Mode

If lane definitions are unavailable and you need emergency local testing, you can enable fallback mode:

```bash
NAP_MCP_SINGLE_AGENT=1 cargo run
```

In fallback mode:
- lane enforcement is relaxed
- server logs a warning
- intended for local/dev use only

Optional override for definition path:

```bash
NAP_MCP_AGENT_DEFINITIONS_PATH=/custom/path/agent_definitions.yaml cargo run
```

### 5. Plan Source Overrides (packaged binary friendly)

Default plan loading uses `<repo>/mcp-server/plans/`.

For packaged binaries or custom deployments, override the source with environment variables:

```bash
# Option A: directory containing one or more *.yaml plan files
NAP_MCP_PLANS_DIR=/custom/plans cargo run

# Option B: explicit plan file path
NAP_MCP_PLANS_PATH=/custom/plans/session.yaml cargo run
```

Selection behavior:
- If `NAP_MCP_PLANS_PATH` is set to a file, that file is used.
- If `NAP_MCP_PLANS_PATH` is set to a directory, that directory is scanned.
- Else if `NAP_MCP_PLANS_DIR` is set, that directory is scanned.
- Else default `<repo>/mcp-server/plans/` is scanned.

Ambiguity rule for `read_assignments`:
- one matching plan file and no `plan_id` -> allowed
- multiple matching plan files and no `plan_id` -> rejected with disambiguation error
- explicit `plan_id` -> selected by `plan_id` value

### 6. Agent Session Registration

Agents register with the server:

```rust
use nap_mcp_server::SessionManager;

let session_manager = SessionManager::new(pool);
session_manager.register_agent("agent-1", "session-2026-02-11").await?;
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   MCP Server                            │
├─────────────────────────────────────────────────────────┤
│  Protocol Layer  │  Tools & Response Schemas           │
├─────────────────────────────────────────────────────────┤
│  Session Manager │  Agent Registration & Tracking      │
├─────────────────────────────────────────────────────────┤
│  Review System   │  Request/Response Loop              │
├─────────────────────────────────────────────────────────┤
│  Plan Dispatcher │  YAML Parser & Task Distribution    │
├─────────────────────────────────────────────────────────┤
│  Report Repo     │  Storage & Queries                 │
├─────────────────────────────────────────────────────────┤
│  NAP Integration │  Telemetry & Compliance            │
├─────────────────────────────────────────────────────────┤
│  SQLite Database │  Persistent Storage                 │
└─────────────────────────────────────────────────────────┘
```

## Data Schemas

### Review Request

```json
{
  "review_request_id": "RR-2026-001",
  "requesting_agent": "agent_a",
  "target_agent": "agent_b",
  "work_package_id": "WORK-SESSION-2026-02-11-1",
  "artifacts_to_review": ["REQ-1", "CODE-A-42"],
  "context": "Implement feature X, review for safety violations",
  "priority": "high",
  "deadline": "2026-02-11T18:00:00Z"
}
```

### Review Response

```json
{
  "review_response_id": "RES-2026-001",
  "review_request_id": "RR-2026-001",
  "reviewing_agent": "agent_b",
  "findings": [
    {
      "severity": "critical",
      "category": "safety_violation",
      "description": "Missing hazard control for feature X",
      "artifact_id": "CODE-A-42"
    }
  ],
  "recommendations": ["Add safety check before feature X execution"],
  "approval_decision": "conditional_approval"
}
```

## Testing

```bash
cargo test
```

Integration tests simulate 4-agent orchestration scenarios:

```bash
cargo test --test integration_test -- --nocapture
```

For a full CLI/IDE smoke test workflow (JSON-RPC initialize/tools/list, DB persistence checks, lane checks, plan ambiguity, fallback mode), see:

- `VERIFICATION_CHECKLIST.md`

## NAP Integration

The MCP server integrates with NAP by:
- Emitting telemetry events for all review completions
- Validating task distribution plans against risk/autonomy classes
- Enforcing interaction contracts between agents
- Linking reviews and reports to NAP trace graph artifacts

## Branch Strategy

This project is developed on the `MCP_Test_Branch` and will be merged to `main` after:
- All tests pass (unit + integration)
- Integration test with 4-agent scenario succeeds
- NAP compliance validation passes
- Documentation is complete

## License

Part of the NexGentic Agents Protocol.
