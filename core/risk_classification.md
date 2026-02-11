# Risk Classification and Tailoring

This document defines the risk classes used by the **NexGentic Agents Protocol (NAP)** and lists the required artifacts and activities for each class. Risk classification tailors the protocol to the potential impact of an agent’s actions, mirroring a high-assurance approach to software classification and tailoring. When in doubt, classify at the higher level. If stakeholders disagree on classification, the **task owner** and **safety officer** should confer. Unresolved disputes may be escalated to the governance board or resolved by the policy engine according to organizational policy.

## Why classify risk?

This protocol requires each system and subsystem containing software to be assigned to a software class based on risk, criticality and mission impact. This classification determines which requirements and assurance activities apply. Similarly, NAP uses risk classes to ensure that tasks with greater potential to cause harm receive more rigorous planning, review and verification. Risk classes are independent of the agent’s internal confidence; they reflect the external consequences if something goes wrong.

## Risk classes

| Class | Description | Examples | Required artifacts |
|---|---|---|---|
| **0 – Minimal** | Tasks with no external side‑effects (read‑only or internal analysis). Failure does not harm people, safety or property. | reading documentation, summarising data | task header, assumptions, plan, minimal logging |
| **1 – Low** | Write operations to non‑critical data sources or systems with straightforward recovery. Failure could inconvenience but not harm. | updating a draft file, creating a test ticket | all Class 0 artifacts plus diff summary, basic unit tests |
| **2 – Medium** | Changes to production systems with moderate impact but no safety‑critical consequences. Failure could cause financial or reputational damage. | modifying business logic, deploying to staging | all Class 1 artifacts plus detailed test plan, independent verification, rollback plan and a preliminary hazard log/screening |
| **3 – High** | Tasks affecting safety‑critical or high‑value assets where failure could harm people, damage hardware or cause mission loss. Equivalent to legacy safety-critical class C–B software. | updating flight software, changing medical device logic | all Class 2 artifacts plus hazard analysis, safety‑critical identification, formal peer review and approval |
| **4 – Critical** | Changes that could lead to catastrophic outcomes if mishandled. Requires multiple independent controls and is analogous to legacy safety-critical class A software. | updating mission‑critical flight control algorithms, modifying life support systems | all Class 3 artifacts plus independent safety review, software assurance plan, formal IV&V and sign‑off by human authority |

**Note:** *Independent verification* refers to review or testing performed by a person or team **not involved in implementing the change**. At a minimum this means the reviewer is a different individual from the one who wrote the code or designed the plan. For Class 2 tasks, a peer who did not contribute to the implementation is sufficient; for Class 3–4 tasks the verification function must be organisationally independent (a separate team or an external contractor) in accordance with IV&V practices. See `safety/testing_and_verification.md` for detailed IV&V requirements. *Formal peer review* means that the review is documented using a checklist, recorded in the configuration management system, and includes sign‑offs from designated reviewers. Informal feedback (e.g., Slack reactions) does not satisfy this requirement.

### Tailoring rules

1. **Classify higher when uncertain.** If a task could plausibly affect safety or critical assets, treat it as Class 3 or 4 and perform hazard analysis accordingly.
2. **Promotion through states.** As tasks progress through planning and verification, re‑evaluate classification based on new information (e.g., if testing reveals hidden hazards, increase the class and add required controls).
3. **No automatic downgrades.** Classification may be downgraded only when a formal hazard analysis demonstrates that the task’s impact is lower than originally assessed and all stakeholders (including the safety officer) agree. Document the rationale and approvals in the trace graph. Unilateral downgrades are prohibited.
4. **Relation to external software class schemes.** The agent classes map roughly to external software class schemes (A–E), where Class 4 approximates the highest-risk safety‑critical software, and Class 0 approximates simple research utilities. Use this mapping to apply relevant external requirements and standards.
5. **Consider autonomy tiers.** Alongside risk class, determine the autonomy tier using `core/agent_autonomy_and_human_oversight.md`. Higher autonomy tiers (A3–A4) combined with high risk may require additional controls, human oversight or formal residual risk acceptance. A4 autonomy is prohibited for Class 0–2 tasks and allowed only under exceptional controls for Class 3–4 tasks.
6. **Mapping is advisory.** Use the legacy safety-critical class mapping as guidance, but the NAP risk class is the authoritative classification for gating. Do not argue based solely on external labels; instead apply NAP rules and quantitative triggers.

### Quantitative triggers and AI examples

While classification focuses on potential consequences, quantitative thresholds help guide decisions and increase consistency. Consider the following triggers when assigning a risk class:

* **Financial impact:** tasks involving transactions over an organisation‑defined threshold (e.g., `FIN_TXN_T2`) should be treated as at least Class 2. High‑value transactions or those affecting multiple accounts may require Class 3. Define thresholds as configuration parameters rather than hard‑coded numbers.
* **Data sensitivity:** tasks handling personal or sensitive data (e.g., personally identifiable information (PII), medical records) warrant a higher class (Class 2 or above) due to legal and ethical implications.
* **Safety exposure:** tasks that control or advise on physical systems (e.g., robotics, medical devices, vehicles) should be Class 3 or 4 depending on the severity of potential harm.
* **Autonomous chain depth:** tasks that autonomously trigger further actions or spawn sub‑agents should be classified at the highest potential impact level of those downstream actions.
* **Reliability and blast radius:** tasks that can impact a large number of users or a wide operational domain should be elevated. For example, if an error could affect more than a predefined number of users (`USER_BLAST_RADIUS_T1`) or exceed a defined error budget, consider raising the class. Quantitative error budgets and blast radius thresholds must be defined by the organisation.

* **Residual risk acceptance:** if risk cannot be fully mitigated despite controls, a formal residual risk acceptance may be required. See `safety/risk_acceptance_and_residuals.md` for the approval process and required documentation.

* **Domain sensitivity:** the subject matter of a task may elevate its risk class. For example, drafting content that offers legal, medical or financial advice is inherently higher risk than composing general marketing copy. When in doubt, bias towards the higher class and involve domain experts during hazard analysis.

#### AI‑specific examples

* Generating an internal knowledge base summary → **Class 0** (read‑only analysis).
* Drafting a user email or blog post → **Class 1** (write to non‑critical systems).
 *Domain matters:* if the email contains legal, medical or financial content, treat it as Class 2 or higher due to elevated consequences.
* Recommending products or content to users based on personal data → **Class 2** (moderate impact, privacy concerns).
* Adjusting pricing or credit decisions based on AI predictions → **Class 3** (financial and ethical implications, requires hazard analysis and human approval).
* Controlling an autonomous drone or vehicle navigation system → **Class 4** (potential for catastrophic harm if malfunction occurs).

These triggers and examples help map AI tasks to appropriate risk classes. When combining multiple factors (e.g., financial and safety impacts), choose the highest class and follow the corresponding requirements.

## Required artifacts by class

The NAP integrates process gates similar to the state machine described in the original protocol. The required deliverables increase with risk class to satisfy the expectation for planning, documentation and independent verification.

| Artifact | Class 0 | Class 1 | Class 2 | Class 3 | Class 4 |
|---|---|---|---|---|---|
| **Task header** (goal, constraints, risk class) | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Assumptions and environment** | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Plan and algorithm description** | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Diff summary / change description** | – | ✓ | ✓ | ✓ | ✓ |
| **Unit tests and self‑verification evidence** | – | ✓ | ✓ | ✓ | ✓ |
| **Detailed test plan and results** | – | – | ✓ | ✓ | ✓ |
| **Rollback and recovery plan** | – | – | ✓ | ✓ | ✓ |
| **Independent verification log** | – | – | ✓ | ✓ | ✓ |
| **Hazard analysis and safety classification** | – | – | preliminary hazard log/screening | ✓ | ✓ |
| **Formal peer review** | – | – | – | ✓ | ✓ |
| **Software assurance plan (IV&V)** | – | – | – | – | ✓ |

The table above summarises typical artifacts. To avoid divergence between narrative and executable requirements, the **machine‑checkable mapping** is defined in `core/risk_tier_artifact_matrix.md`. Policy engines should rely on that matrix for enforcement rather than duplicating this table.

### Linking to other sections

* **Requirements capture:** After determining risk class, consult `core/requirements_management.md` to elicit, document and validate requirements. Risk class influences the depth of hazard analysis and safety constraints.
* **Architecture and design:** Higher‑risk classes require documented architecture and design reviews (`core/architecture_design.md`) to ensure that system decomposition supports hazard controls.
* **Testing and verification:** Use `safety/testing_and_verification.md` for building test plans, code coverage and IV&V appropriate to the risk class.
* **Safety and assurance:** For Class 3 and 4, perform hazard analysis and software assurance per `safety/safety_and_assurance.md`.
* **Configuration and risk management:** Log each configuration item and risk in `core/configuration_and_risk_management.md` and record hazard controls in the hazard log template.
* **Agent autonomy:** Determine the autonomy tier for each task using `core/agent_autonomy_and_human_oversight.md`. Autonomy and risk classes together inform approvals and oversight.
* **Residual risk:** When risks remain after mitigation, follow `safety/risk_acceptance_and_residuals.md` to document and obtain approval for residual risks.
* **Traceability:** Assign unique identifiers to tasks, requirements and hazard controls and capture them in a traceability matrix (`core/traceability_and_documentation.md`) to support audits and impact analysis.

* **Economic and performance modelling:** When assigning risk classes, consider the economic and performance implications of the task. Use `evaluation/economic_and_performance_risk_modeling.md` to incorporate cost, latency and business impact into your classification decisions.

**Note on economic influences:** Economic and performance factors may **raise** the risk class (e.g., tasks with high potential loss or harm require stricter controls) but should not be used to **lower** the class. Do not down‑classify a safety‑critical task simply because it is expensive to implement or impacts delivery timelines.

By following this classification and tailoring approach, tasks of differing consequence can be managed with the appropriate level of rigor, aligning the NAP with risk-based high-assurance software engineering practices.






