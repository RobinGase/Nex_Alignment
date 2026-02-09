# Probabilistic Release Gate: Worked Example

Probabilistic assurance allows AI systems to release updates when statistical evidence suggests that the system is safe and reliable. This document provides a **worked example** of a probabilistic release gate, illustrating how to apply statistical tests, compute confidence intervals and decide whether to proceed or rollback.

## Scenario

An AI model (risk class 3, autonomy tier A2) is being updated. The policy requires that the release only proceed if the model’s **error rate** on a validation set is less than 1 % and that the **95 % confidence interval** for the error rate is narrower than 0.05 (absolute width). A canary deployment of 5 % of traffic is planned. Data drift thresholds are monitored with PSI.

## Steps

1. **Evaluate validation metrics.** The model is tested on a hold‑out set of 10,000 examples. It produces 85 errors (error rate = 0.85 %).
2. **Compute confidence interval.** Assume errors follow a binomial distribution. Using a normal approximation, the standard error (SE) = √(p (1 − p)/n) ≈ √(0.0085 × 0.9915 / 10 000) ≈ 0.0009. The 95 % confidence interval = p ± 1.96 × SE ≈ 0.0085 ± 0.0018, yielding an interval width of 0.0036.
3. **Check probabilistic gate.** The error rate (0.85 %) is below the 1 % threshold and the interval width (0.0036) is below the 0.05 threshold. The probabilistic gate passes. A `policy_engine` emits an approval event with metrics.
4. **Monitor canary rollout.** During the canary, drift detectors compare live data to the validation distribution. The PSI remains below 0.2, so no drift alert is triggered. The model’s error rate remains consistent.
5. **Full rollout.** After canary success, the deployment is expanded. Drift and variance continue to be monitored. If PSI exceeds 0.25 or the error rate increases significantly, the policy engine triggers a rollback.

## Enforcement trigger example

Suppose that during the canary, PSI jumps to 0.35. The drift detector emits a `variance_threshold_exceeded` event. The policy engine receives this event and fails the release gate. It emits a `policy_violation` event with metrics and instructs the deployment pipeline to rollback. The release is halted until drift is investigated and addressed.

## Linking to other sections

* **Probabilistic assurance metrics:** See `evaluation/probabilistic_assurance_and_release_metrics.md` for definitions and formulas.
* **Compliance scoring:** Drift incidents and gating failures feed into the compliance score (`runtime/compliance_scoring_and_metrics.md`).
* **Telemetry:** Events for gate approval or failure follow the `runtime/telemetry_schema.md` and examples in `runtime/telemetry_example_streams.md`.
* **Policy engine:** The enforcement logic is specified in `runtime/compliance_runtime_spec.md` and `runtime/enforcement_and_policy_engine.md`.

By providing explicit numbers and calculations, this example turns probabilistic assurance from a concept into a **measurable enforcement mechanism**. Organisations can adjust thresholds and sample sizes according to domain requirements while maintaining consistent enforcement patterns.



