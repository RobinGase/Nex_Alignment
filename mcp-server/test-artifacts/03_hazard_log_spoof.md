# Hazard Log (Spoof)

| Hazard ID | Description | Severity | Software Components Involved | Causes | Controls (Design/Procedural/Operational) | Verification Activities | Status | Residual Risk Acceptance |
|---|---|---|---|---|---|---|---|---|
| HAZ-1 | Agent accesses files outside assigned scope | Critical | `src/session/manager.rs`, `src/orchestration/parser.rs` | Missing scope validation | CTL-1 scope whitelist, CTL-2 interaction contract | TST-1, TST-2 | Closed | RIS-1 (conditional) |
| HAZ-2 | Review chain missing decision evidence | Marginal | `src/review/system.rs`, `src/reports/repository.rs` | Incomplete payload | CTL-3 required fields validation | TST-3 | Closed | none |
| HAZ-3 | Invalid plan accepted by dispatcher | Critical | `src/orchestration/validator.rs` | Weak validation rules | CTL-4 risk/autonomy checks, CTL-5 fail-closed behavior | TST-4, TST-5 | Closed | none |
