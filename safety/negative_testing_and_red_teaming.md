# Negative Testing, Adversarial Evaluation and Red Teaming

Testing is not complete until systems are exercised under adverse conditions. In addition to functional and performance tests, AI systems must be exposed to malicious inputs, prompt injections, adversarial examples and stress scenarios to uncover vulnerabilities. NIST’s guidance on adversarial machine learning describes automated model‑based red teaming, where attackers use classifiers as reward functions to train generative models for jailbreaking and multi‑turn adaptive attacks. This document describes negative testing and red teaming practices within the **NexGentic Agents Protocol (NAP)**.

## Why negative testing?

Traditional testing focuses on verifying correct behaviour for valid inputs. However, AI agents may encounter malicious or unexpected inputs in practice. Negative testing helps ensure:

* **Robustness to adversarial inputs.** Identify vulnerabilities that could lead to mis‑behaviour, data leaks, prompt injections or harmful actions.
* **Security hardening.** Validate that input validation, sanitisation and filtering mechanisms are effective.
* **Resilience to stress and fault conditions.** Ensure that systems remain safe under overload, resource exhaustion or infrastructure failures.
* **Preparation for emerging threats.** Red teaming simulates adversary strategies to drive continuous improvement.

## Negative testing techniques

1. **Malicious input testing.** Craft inputs with SQL injection, command injection, cross‑site scripting or other attack patterns. For LLM agents, include prompt injection strings (e.g., “ignore previous instructions,” “delete all files”). Verify that the agent correctly sanitises or rejects these inputs.
 **Safety note:** All destructive or invasive test patterns MUST be executed in sandboxed, non‑production environments with appropriate isolation. Tools used for malicious input testing must not have privileges to access live data or production resources.
2. **Fuzzing.** Use automated fuzzers to supply random or semi‑structured data to inputs. For text prompts, mutate strings, insert control characters or generate synthetic adversarial samples using generative models.
3. **Adversarial examples.** For machine learning models (e.g., vision or NLP classifiers), generate adversarial examples that cause misclassification. Evaluate the impact and update models or defences accordingly.
4. **Prompt injection and jailbreak testing.** Create test cases where malicious instructions are embedded in user queries, system messages or data. Attempt multi‑turn adaptive attacks where the attacker modifies prompts based on the agent’s previous responses.
 **Data exfiltration tests:** Include scenarios where adversaries attempt to retrieve secrets or proprietary information (e.g., personal data, API keys, confidential prompts). Evaluate whether the model reveals sensitive information in its responses or logs.
5. **Chaos engineering.** Inject faults in infrastructure (e.g., shutting down services, network latency) or degrade model performance intentionally to observe system resilience and fail‑safe behaviour. Ensure that rollback and fail‑over mechanisms activate without causing unsafe states.
6. **Fault injection.** Deliberately trigger exceptions or simulate corrupted data. Confirm that error handling works as intended and that hazard controls remain effective.

## Red teaming process

1. **Define objectives and scope.** Identify the aspects of the system to be tested (prompt handling, input validation, model robustness, security surfaces). Determine attack goals (e.g., exfiltrate data, cause unsafe actions).
2. **Assemble a diverse team.** Involve individuals with security expertise, adversarial ML knowledge and domain familiarity. Include “friendly adversaries” who can think like attackers.
3. **Execute attacks and record findings.** Use manual and automated techniques to probe the system. Record successful attack vectors, reproduction steps and observed impacts. For each vulnerability, create a hazard log entry and update risk and hazard controls.
4. **Prioritise and remediate.** Assess the severity of each finding. Prioritise critical vulnerabilities that could lead to high‑risk outcomes. Implement mitigations (e.g., input sanitisation, additional filters, model retraining) and re‑test.
 **Severity scoring and must‑fix thresholds:** Assign a severity score to each finding (e.g., Low, Medium, High, Critical). For Class 3–4 tasks, findings rated High or Critical MUST be remediated and validated before deployment. The policy engine shall enforce a **No‑Go** gate for releases with unmitigated Critical findings.
5. **Continuous red teaming.** Perform adversarial evaluations periodically, especially before major releases or when models, prompts or infrastructures change. Use metrics to track improvements over time.

## Integration with NAP

* **Testing and verification:** Negative testing and red teaming should be integrated into `safety/testing_and_verification.md` for Class 2–4 tasks. Define specific adversarial test cases and include them in test plans.
* **Risk and hazard analysis:** Record vulnerabilities discovered during red teaming as hazards or risks in the hazard log and risk register. Mitigate them with controls and residual risk acceptance if necessary (`safety/safety_and_assurance.md`, `safety/risk_acceptance_and_residuals.md`).
* **Configuration management:** Treat adversarial test scripts and red team reports as configuration items (`core/configuration_and_risk_management.md`). Version and review them as part of the overall quality process.
* **AI‑specific considerations:** For LLMs and generative models, include prompt injections, instruction-tampering and model hallucination tests in the adversarial suite (`safety/ai_specific_considerations.md`).
* **Operations and monitoring:** Incorporate patterns identified by red teaming into runtime monitoring and intrusion detection. Use anomaly detection and alerting mechanisms to detect similar attacks in production (`safety/operations_and_maintenance.md`).

By incorporating negative testing, adversarial evaluation and red teaming into the NAP, organisations can proactively identify and mitigate vulnerabilities in AI systems, enhancing robustness and safety against evolving threats.



