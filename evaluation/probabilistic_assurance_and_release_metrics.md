# Probabilistic Assurance and Release Metrics

Traditional software assurance often treats verification as a binary pass/fail activity. AI systems and complex multi‑agent environments require a more nuanced view of reliability that considers statistical variability, confidence intervals and continuous performance monitoring. NIST’s AI risk management guidance emphasises the need to assess and document system variance using techniques such as confidence intervals, standard deviation and bootstrapping. This document defines probabilistic assurance practices and release gating metrics within the **NexGentic Agents Protocol (NAP)**.

## Why probabilistic assurance?

1. **Inherent uncertainty.** Machine learning models produce outputs based on probability distributions rather than deterministic logic. Two runs of the same model may yield slightly different results due to randomness in training, inference or sampling processes.
2. **Operational variability.** Real‑world environments vary, and AI systems may encounter data distributions and contexts not present during development. Measuring expected performance across different conditions requires statistical analysis.
3. **Risk‑informed decision making.** Decisions about deployment, rollback and re‑training must account for confidence in performance metrics, not just average values. A high mean performance with wide confidence intervals may still imply unacceptable risk.

## Key probabilistic metrics

1. **Confidence intervals and hypothesis tests.** For each critical performance metric (e.g., accuracy, false‑positive rate, fairness), compute confidence intervals (e.g., 95 % confidence) using techniques such as bootstrapping. Use hypothesis tests to compare model versions and determine if observed differences are statistically significant.
2. **Variance and standard deviation.** Track the variance of metrics across different datasets, time periods and simulation runs. High variance may indicate sensitivity to environment changes or data drift. Document standard deviations alongside mean values.
3. **Coverage of error cases.** Measure the proportion of edge cases and rare events included in evaluation datasets. Use techniques like importance sampling to estimate how performance scales to these cases.
4. **Confidence thresholds.** Define minimum acceptable confidence levels for key metrics. For example, require that the lower bound of a 95 % confidence interval for safety‑critical accuracy exceeds a threshold (e.g., 99 %). Use these thresholds to gate deployment.
5. **Reliability indices.** Compute composite reliability indices that combine multiple metrics (accuracy, latency, resource usage). Weigh each component according to risk class and business priorities. Monitor the index over time to detect degradation.

### Reliability index and unified decision model

To integrate probabilistic metrics into the **unified governance decision model**, NAP defines a **ReliabilityIndex** (0–1) combining error rate, drift measures and confidence interval width. See `runtime/unified_governance_decision_model.md` for a full definition and worked example. In brief, the index is:

\[
\text{ReliabilityIndex} = w_1 \times (1 - \text{ErrorRate}) + w_2 \times (1 - \text{DriftMetric}) + w_3 \times \left(1 - \frac{\text{ConfidenceIntervalWidth}}{\text{MaxWidth}}\right)
\]

Weights `w_1`, `w_2` and `w_3` must sum to 1 and reflect organisational priorities. In NAP these weights are defined by the **`WEIGHTS_W1`, `W2`, `W3`** parameters in the `core/governance_parameter_registry.md`. Teams MAY adjust weights but must maintain the sum and record rationale in the registry. The **Probabilistic penalty** in the unified decision model subtracts points when the reliability index falls below the **`RELIABILITY_THRESHOLD`** parameter. By explicitly defining the reliability index and linking its components to parameter IDs, NAP turns probabilistic assurances into a quantitative governance input rather than a narrative description.

#### Default drift metric and interval width

To operationalise the reliability index, NAP specifies defaults and justification requirements for its parameters:

* **DriftMetric.** Use the **population stability index (PSI)** as the default drift metric. PSI compares the distribution of input features or outputs between the training data and current data; normalise the PSI to a \\[0, 1\] scale where 0 means no drift and 1 means maximum drift. Teams MAY choose alternative drift metrics (e.g., Kullback–Leibler divergence) but MUST justify the choice and document how the metric is normalised and what thresholds are used. The chosen drift metric and threshold must be recorded in the test report and trace graph.
* **MaxWidth.** Define `MaxWidth` as the largest acceptable width of the 95 % confidence interval for the key safety metric (e.g., error rate or failure rate). The governance board should set domain‑specific values (e.g., 0.05 for critical accuracy). Projects MAY use tighter bounds but must never exceed the organisational maximum. Document the `MaxWidth` value and rationale in the test plan.

> **Parameter references.** The default drift metric and maximum confidence interval width are defined in the `core/governance_parameter_registry.md` via the **`DRIFT_METRIC_DEFAULT`** and **`MAX_WIDTH_DEFAULT`** parameters. Organisations MUST reference these parameters rather than hard‑coding values in project documentation. When a team selects an alternative drift metric or changes the maximum interval width, they MUST update the parameter registry with the new value and justification, and record the decision in the trace graph. This ensures consistency and auditable change control across the protocol.

By defining a default drift metric and bounding the confidence interval width, NAP ensures that probabilistic assurance metrics are comparable and enforceable across projects while allowing flexibility when justified.

## Release gating and canary deployments

1. **Canary testing.** Before full release, deploy new models or features to a small subset of users or agents (the “canary” group). Measure performance and safety metrics for the canary and compute confidence intervals. Compare against baseline versions using hypothesis tests. Promote the update only if performance improves or remains within defined bounds.
2. **Statistical release gates.** Integrate probabilistic criteria into the policy engine (`runtime/enforcement_and_policy_engine.md`). For example, require that 95 % confidence intervals for key metrics exceed thresholds and that variance does not increase beyond a defined margin. Automate these checks in CI pipelines and deployment workflows.
3. **Runtime safety metrics.** Define runtime safety metrics, such as anomaly rate, hazard invocation rate and kill‑switch activations. Compute rolling confidence intervals for these metrics and set alert thresholds. Use statistical process control to detect anomalies and trigger rollback or escalation.
4. **Veto conditions and hard stops.** Some safety events override all other probabilistic criteria. Define **hard veto thresholds** for metrics such as kill‑switch activations, hazard invocation counts or contract violations. For example, any kill‑switch activation, or more than *X* hazardous events during canary testing, must result in an immediate **No‑Go** decision, regardless of the computed reliability index or other metrics. Hard veto thresholds reflect the principle that certain safety breaches cannot be offset by good statistical performance. Document these thresholds in the policy configuration and link them to the unified governance decision model.
5. **Post‑release monitoring.** After deployment, continuously collect performance data and update confidence intervals. Use control charts and hypothesis tests to detect drift. If metrics cross alert thresholds, initiate re‑evaluation, re‑training or rollback.

## Implementation guidance

1. **Metric collection and storage.** Define a standard schema for storing metric values, sample sizes and confidence intervals. Tag metrics with the model version, dataset, timestamp and risk class. Use time‑series databases or metric stores for efficient retrieval.
2. **Integration with compliance telemetry.** Feed probabilistic metrics into compliance dashboards (`runtime/compliance_telemetry_and_governance_drift.md`). Add advanced metrics such as “mean vs. worst‑case performance gap” and “confidence interval width” to the protocol health score.
3. **Policy engine hooks.** Extend the policy engine to evaluate probabilistic criteria before approving releases. Provide human reviewers with metric visualisations and statistical reports.
4. **Documentation.** Document statistical methods, datasets and assumptions used to calculate metrics. Include rationale for confidence thresholds and release criteria. Link metric reports to requirements and hazards via the trace graph (`core/trace_graph_schema.md`).

## Linking to other sections

* **Testing and verification:** Incorporate probabilistic metrics into test reports (`safety/testing_and_verification.md`) and summarise them in verification logs. Use statistical analyses to validate changes.
* **AI‑specific considerations:** Uncertainty and drift monitoring guidance in `safety/ai_specific_considerations.md` informs the selection of metrics and thresholds. Use these metrics to trigger re‑training when drift is detected.
* **Risk classification:** Adjust risk classes or autonomy tiers when probabilistic metrics indicate increased uncertainty or decreased reliability.
* **Economic and performance modelling:** Consider the cost implications of tighter confidence thresholds or longer canary phases (`evaluation/economic_and_performance_risk_modeling.md`). Balance risk reduction with business impact.

By formalising probabilistic assurance, NAP acknowledges that high assurance in AI systems is not an absolute guarantee but a statistical commitment. Requiring confidence‑based metrics for release gating and continuous monitoring helps detect subtle degradation and ensures that AI agents meet reliability targets even under uncertain and evolving conditions.



