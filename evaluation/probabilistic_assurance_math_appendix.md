# Probabilistic Assurance: Mathematical Appendix

High‑assurance AI governance requires more than narrative descriptions of uncertainty; it demands well‑defined statistical models, canonical formulas and calibration procedures. This appendix complements `evaluation/probabilistic_assurance_and_release_metrics.md` by formalising the mathematics behind the metrics and outlining testable validation steps. It draws on NIST guidance that AI systems must assess variance using confidence intervals, standard deviations and bootstrapping and that drift detection should employ statistical hypothesis tests.

## 1. Statistical foundations

1. **Error rate and accuracy.** Let \(n\) be the number of evaluation samples and \(k\) the number of misclassified or unsafe outcomes. The observed **error rate** is \(\hat{p} = k/n\) and **accuracy** is \(1 - \hat{p}\). To compute confidence intervals for \(\hat{p}\), use the Wilson score interval or Clopper–Pearson exact interval for binomial proportions. The 95 % Wilson interval bounds are:
 \[
 \hat{p} \pm z_{0.975} \sqrt{ \frac{\hat{p}(1 - \hat{p}) + z_{0.975}^2/(4n)}{n + z_{0.975}^2} }
 \]
 where \(z_{0.975} \approx 1.96\). Record \(\text{ConfidenceIntervalWidth} = \text{upper} - \text{lower}\) in reliability calculations.

2. **Variance and standard deviation.** For continuous performance metrics (e.g., latency, resource usage), compute the sample standard deviation \(s\) and variance \(s^2\). Use these to estimate the spread of the metric and to compute standard errors (\(s/\sqrt{n}\)). When combining metrics across environments, weight variances appropriately.

3. **Hypothesis tests.** When comparing two model versions, use tests such as the McNemar test (for paired classification tasks), Student’s t‑test (for continuous metrics) or bootstrap resampling. Define null hypotheses (no difference) and compute p‑values. Reject the null when p < \(\alpha\) (e.g., 0.05) and document the effect size.

## 2. Drift metrics

1. **Population stability index (PSI).** Partition each feature or output distribution into bins. For each bin \(i\), compute the proportions \(p_i\) (baseline) and \(q_i\) (current). The PSI is:
 \[
 \text{PSI} = \sum_{i} (q_i - p_i) \times \ln \frac{q_i}{p_i}
 \]
 Normalise PSI to the range \([0,1]\) by dividing by a domain‑specific maximum or using a logistic transform. Use the normalised PSI as the **DriftMetric** in the reliability index.

2. **Kullback–Leibler divergence (KL).** For probability distributions \(P\) and \(Q\), the KL divergence is \(D_{\mathrm{KL}}(Q \parallel P) = \sum_i q_i \ln (q_i/p_i)\). KL is asymmetric and unbounded. When using KL as the drift metric, normalise via \(\text{DriftMetric} = \frac{D_{\mathrm{KL}}}{D_{\mathrm{KL}} + 1}\). Select binning or density estimation methods consistent with the feature type.

3. **Jensen–Shannon divergence (JSD).** A symmetric variant of KL defined as \(\tfrac{1}{2} D_{\mathrm{KL}}(P \parallel M) + \tfrac{1}{2} D_{\mathrm{KL}}(Q \parallel M)\), where \(M = \tfrac{1}{2}(P+Q)\). JSD is bounded between 0 and 1 and may be easier to interpret for multi‑modal distributions.

Teams may choose alternative drift metrics but MUST document the choice, provide normalisation and define alert thresholds. Use hypothesis tests such as the Kolmogorov–Smirnov test to determine if drift is statistically significant.

## 3. Calibration and reliability modelling

1. **Reliability diagrams.** Plot predicted probabilities against observed frequencies. Compute **expected calibration error (ECE)** and **maximum calibration error (MCE)** to quantify miscalibration. For a model to be considered calibrated, ECE should be below a domain‑specific threshold (e.g., < 0.05). If calibration is poor, recalibrate using techniques such as Platt scaling or isotonic regression.

2. **Confidence interval width normalisation.** To compute \(\text{ConfidenceIntervalWidth}/\text{MaxWidth}\) in the reliability index, divide the 95 % interval width by the maximum width defined by the governance board (see `evaluation/probabilistic_assurance_and_release_metrics.md`). Ensure that interval widths are derived from calibrated models; otherwise, widen intervals accordingly.

3. **Reliability index weighting.** Choose weights \(w_1, w_2, w_3\) based on risk class and domain. For safety‑critical tasks, assign greater weight to error rate and drift (e.g., \(w_1=0.6, w_2=0.3, w_3=0.1\)). Document weight selections and obtain governance board approval. Avoid weights that could permit poor reliability to be masked by good performance on secondary metrics.

## 4. Confidence interval validation tests

1. **Bootstrap validation.** Perform bootstrap resampling (e.g., 1,000 replicates) to estimate the distribution of the performance metric. Compute the bootstrap confidence interval and compare it with the analytic interval (e.g., Wilson). Large discrepancies suggest miscalibration or non‑independent samples.

2. **Goodness‑of‑fit tests.** Use tests such as the chi‑squared goodness‑of‑fit test to evaluate whether observed frequencies match expected distributions. For calibration, verify that predicted quantiles align with observed quantiles (probability integral transform).

3. **Diagnostic plots.** Generate quantile–quantile plots, reliability diagrams and cumulative error plots. Include these visuals in verification reports. Reviewers should confirm that uncertainty estimates behave as expected.

## 5. Worked example

Consider a binary classifier evaluated on 10,000 samples where 50 errors occur (\(\hat{p}=0.005\)). The 95 % Wilson confidence interval for the error rate is approximately 0.0037–0.0067 (width = 0.003). Suppose the maximum allowed width (`MaxWidth`) is 0.01, the drift metric (normalised PSI) is 0.2 and weights \(w_1=0.5, w_2=0.3, w_3=0.2\). The reliability index is then:

\[
\text{RI} = 0.5\times (1 - 0.005) + 0.3\times (1 - 0.2) + 0.2\times (1 - 0.003/0.01) = 0.5\times 0.995 + 0.3\times 0.8 + 0.2\times 0.7 = 0.4975 + 0.24 + 0.14 = 0.8775.
\]

If the governance board sets a reliability threshold of 0.9, the probabilistic penalty is \(P_p = 100\times \max(0, 0.9 - 0.8775) = 2.25\) points (see `runtime/unified_governance_decision_model.md`). This numeric example illustrates how small changes in error rate, drift or confidence interval width affect the reliability index and the final governance score.

## 6. References and further reading

* **NIST AI Risk Management Framework.** For guidance on measuring AI system variance and drift, see the “Measure” section.
* **Statistical methods.** Agresti, A. (2018). *Statistical Methods for the Social Sciences* (5th ed.). Pearson. Chapter 10 provides detailed discussion of confidence intervals for proportions.
* **Drift detection surveys.** Gama, J., Žliobaitė, I., Bifet, A., Pechenizkiy, M., & Bouchachia, A. (2014). “A survey on concept drift adaptation.” *ACM Computing Surveys*, 46(4), 44.

By grounding probabilistic assurance in formal statistics and providing reproducible calculation steps, this appendix supports rigorous, evidence‑based risk decisions within NAP. Auditors and teams should reference these formulas when computing metrics and calibrating models.


