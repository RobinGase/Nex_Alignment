# Agent Autonomy Levels and Human Oversight

The **NexGentic Agents Protocol (NAP)** assigns risk classes based on potential consequences. Complementary to risk classification, agents may operate at different levels of autonomy. Defining autonomy tiers clarifies which decisions the AI can make independently and when human intervention is required. NIST notes that AI systems are designed to operate with varying levels of autonomy and that human roles must be clearly defined when overseeing AI systems. This document introduces an autonomy tier model and guidelines for human oversight.

## Autonomy tier model

NAP defines five autonomy tiers (A0–A4) to describe the degree of agent independence. These tiers are separate from the risk classes in `core/risk_classification.md`, but they interact: higher autonomy combined with high‑risk tasks requires more stringent controls and approvals.

| Tier | Description | Typical actions | Oversight requirements |
|---|---|---|---|
| **A0 – Advisor (suggest‑only)** | The agent provides recommendations, summaries or analyses but cannot execute actions that affect external systems or data. | Summarising documents, suggesting code changes, recommending options. | Results reviewed by a human before any action is taken. |
| **A1 – Assistive (reversible actions)** | The agent can perform actions that are easily reversible and have minimal consequences. Requires a human to confirm before final commit. | Editing draft documents, creating tickets, staging code changes. | Human review and confirmation required before deploying or merging. |
| **A2 – Autonomous with approval (irreversible but controlled actions)** | The agent prepares actions with potential external side‑effects but cannot execute them without explicit human approval. | Deploying code to production, changing configuration parameters, generating and sending official communications. | Human must review and approve or reject the prepared action. The system should enable easy rollback. |
| **A3 – Supervised autonomy (bounded autonomy)** | The agent operates semi‑autonomously within predefined safety boundaries. It can make decisions and execute tasks while monitoring by humans or automated safeguards. | Controlling a robot in a safe zone, adjusting system parameters within limits. | Continuous monitoring. If boundaries are breached or uncertainty is high, the system triggers alerts and may halt. Regular audits of actions. |
| **A4 – Full autonomy (self‑governing)** | The agent can make decisions and act without immediate human intervention, subject to overarching safety and ethical constraints. This tier applies to scenarios where human oversight is impractical or harmful due to latency or scale. | Autonomous vehicles in remote environments, automated spacecraft operations. | Pre‑mission approval required. Hazard analysis and safety assurance must demonstrate that risk controls are adequate. Real‑time telemetry monitoring and kill‑switch mechanisms are mandatory. |

### Selecting autonomy tiers

1. **Assess task characteristics.** Consider the environment, potential consequences and reversibility of actions. Align the autonomy tier with the risk class: low‑risk tasks may operate at higher autonomy tiers (e.g., Class 0 tasks could be A1–A2), whereas high‑risk tasks should be limited to A2 or below unless thoroughly justified.
2. **Define safety boundaries.** For A3–A4 tasks, define safety boundaries such as operational envelopes, maximum authority limits or explicit constraints. Document these boundaries in the task header and hazard analysis.
3. **Determine approval requirements.** For A2 tasks, specify who must approve actions. For A3–A4 tasks, specify who monitors operations and under what conditions human intervention is triggered.
4. **Interface with risk classification.** If a task has high potential impact (Class 3–4) but requires A3 or A4 autonomy, ensure that hazard controls, risk acceptance and assurance activities are commensurate. Residual risk acceptance must be formally documented (`safety/risk_acceptance_and_residuals.md`).

## Human oversight guidelines

The NIST AI RMF highlights that human roles and responsibilities must be clearly defined when overseeing AI systems. Additionally, human cognitive biases can influence decisions across the lifecycle, so operators must be trained to recognise these biases. NAP adopts the following guidelines:

1. **Role definition and authority.** Assign operators, approvers and monitors based on the autonomy tier and risk class. Document roles in the task header and hazard log.
2. **Training and bias mitigation.** Provide training on AI limitations, uncertainty interpretation and cognitive bias awareness. Operators should learn how to calibrate trust in AI outputs and recognise when to override decisions.
3. **Kill‑switch and override mechanisms.** Implement mechanisms to halt or override agent actions at any autonomy tier. These should be accessible and tested regularly (see `safety/safety_and_assurance.md`).
4. **Escalation paths.** Define procedures for escalating issues when uncertainty is high, emergent behaviours occur or the agent approaches safety boundaries. Document escalation contacts and timeframes.
5. **Audit and feedback.** Log operator interventions and the rationale. Use this data to improve models, adjust autonomy levels and refine training programmes. Periodically review logs for patterns of over‑ or under‑trust.

## Linking to other sections

* **Risk classification:** When classifying tasks in `core/risk_classification.md`, also determine the appropriate autonomy tier based on the reversibility and potential impact of actions.
* **Requirements and design:** Document autonomy tiers and safety boundaries in requirements (`core/requirements_management.md`) and architecture (`core/architecture_design.md`). Ensure designs include control interfaces for human oversight.
* **Safety and assurance:** Incorporate autonomy tiers and human oversight requirements into hazard analysis (`safety/safety_and_assurance.md`) and ensure that hazard controls account for different autonomy levels.
* **Testing and verification:** Test human‑in‑the‑loop workflows and escalation mechanisms (`safety/testing_and_verification.md`). Perform simulations to ensure kill‑switch mechanisms work as intended.
* **Operations and maintenance:** Define operational procedures based on autonomy tier, including monitoring frequency, operator staffing and incident response (`safety/operations_and_maintenance.md`).
* **Risk acceptance:** If full autonomy (A4) is required for high‑risk tasks, obtain formal residual risk acceptance from the appropriate authority (`safety/risk_acceptance_and_residuals.md`).

By combining autonomy tier classification with the existing risk classes, NAP provides a nuanced framework that balances agent independence with safety and accountability. Clear human oversight expectations and escalation procedures ensure that AI agents operate within safe and ethically acceptable boundaries.



