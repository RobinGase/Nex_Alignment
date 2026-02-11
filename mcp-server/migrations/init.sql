-- agents table
CREATE TABLE IF NOT EXISTS agents (
    agent_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    assigned_files TEXT NOT NULL,
    constraints TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TEXT NOT NULL
);

-- review_requests table
CREATE TABLE IF NOT EXISTS review_requests (
    request_id TEXT PRIMARY KEY,
    requesting_agent TEXT NOT NULL,
    target_agent TEXT NOT NULL,
    work_package_id TEXT NOT NULL,
    artifacts_to_review TEXT,
    context TEXT,
    priority TEXT,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TEXT NOT NULL,
    deadline TEXT,
    FOREIGN KEY (requesting_agent) REFERENCES agents(agent_id),
    FOREIGN KEY (target_agent) REFERENCES agents(agent_id)
);

-- review_responses table
CREATE TABLE IF NOT EXISTS review_responses (
    response_id TEXT PRIMARY KEY,
    request_id TEXT NOT NULL,
    reviewing_agent TEXT NOT NULL,
    findings TEXT NOT NULL,
    recommendations TEXT,
    approval_decision TEXT,
    signature TEXT,
    created_at TEXT NOT NULL,
    FOREIGN KEY (request_id) REFERENCES review_requests(request_id),
    FOREIGN KEY (reviewing_agent) REFERENCES agents(agent_id)
);

-- reports table
CREATE TABLE IF NOT EXISTS reports (
    report_id TEXT PRIMARY KEY,
    agent_id TEXT NOT NULL,
    report_type TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

-- telemetry_events table
CREATE TABLE IF NOT EXISTS telemetry_events (
    event_id TEXT PRIMARY KEY,
    event_type TEXT NOT NULL,
    agent_id TEXT,
    severity TEXT,
    description TEXT,
    payload TEXT,
    created_at TEXT NOT NULL
);

-- task_plans table
CREATE TABLE IF NOT EXISTS task_plans (
    plan_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    orchestrator TEXT NOT NULL,
    risk_class INTEGER NOT NULL,
    autonomy_tier TEXT NOT NULL,
    plan_content TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_agents_session ON agents(session_id);
CREATE INDEX IF NOT EXISTS idx_review_requests_target ON review_requests(target_agent);
CREATE INDEX IF NOT EXISTS idx_review_requests_status ON review_requests(status);
CREATE INDEX IF NOT EXISTS idx_reports_agent ON reports(agent_id);
CREATE INDEX IF NOT EXISTS idx_telemetry_events_type ON telemetry_events(event_type);
