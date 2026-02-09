# Dataset and Model Documentation Template

Use this template to document datasets and models for AI systems in the **NexGentic Agents Protocol (NAP)**. Proper documentation supports provenance, versioning, bias analysis and supply chain security. Complete a separate copy of this template for each dataset or model version. Store completed documentation under configuration management and link it to traceability IDs.

## Metadata

- **Name:**
- **Identifier:** (e.g., `DATASET-1`, `MODEL-2`)
- **Version:**
- **Release date:**
- **Decommission date (if applicable):**
- **Owner/maintainer:**
- **License:**

## Provenance and lineage

- **Origin:** Describe the source of the data or model (e.g., sensor, public dataset, synthetic generator, pre‑trained model). Include information on previous versions or parent models.
- **Collection process:** How was the data collected or the model trained? Include sampling methods, pre‑processing steps and labelling procedures.
- **Transformations:** Document any transformations, augmentations or fine‑tuning applied to produce this version.
- **Lineage:** For models, list parent models and training datasets used. For datasets, describe relationships to previous versions.

## Composition and characteristics

- **Content description:** Summarise what the dataset or model contains (e.g., text corpus, sensor readings, images) and its intended use.
- **Size:** Number of records, file size, number of parameters (for models).
- **Data types and formats:** e.g., JSON, CSV, image formats.
- **Class distribution / label statistics:** (for supervised datasets)
- **Model architecture:** (for models) Describe the architecture, number of layers, activation functions, etc.
- **Parameter count:** (for models)

## Quality, bias and limitations

- **Quality assessment:** Describe data quality checks performed, error rates, noise levels or missing data.
- **Bias notes:** Identify known biases, sampling limitations or imbalance in the data. For models, report bias metrics and fairness evaluations. Note any demographic or contextual limitations.
- **Limitations:** Describe limitations of the dataset or model, including domains or conditions where it should not be used.

## Security and privacy considerations

- **Sensitive content:** Indicate whether the dataset contains personal data, proprietary information or other sensitive content. Document anonymisation or de‑identification steps.
- **Security vulnerabilities:** For models, list known vulnerabilities (e.g., susceptibility to adversarial attacks, poisoning risks). For datasets, note contamination risks.
- **Third‑party components:** Describe any third‑party libraries, pre‑trained models or external datasets incorporated. Include licensing and vetting status.

## Verification and signing

- **Checksum/Hash:** Provide a hash (e.g., SHA‑256) of the dataset or model artefact.
- **Digital signature:** Attach a digital signature for the artefact metadata to ensure authenticity and tamper evidence.
- **Verification process:** Describe how to verify the integrity of the artefact (e.g., check signature using public key, compare hash).

## Maintenance and updates

- **Version history:** Briefly describe previous versions and major changes.
- **Update frequency:** Planned update or re‑training schedule.
- **Deprecation policy:** Criteria for retiring this dataset or model.
- **Monitoring and drift detection:** Methods for monitoring performance and detecting drift or degradation over time.

## Linking

- **Traceability IDs:** List associated traceability identifiers (e.g., `REQ-#`, `COD-#`, `RIS-#`).
- **Risk register entries:** Note any risks associated with this artefact and mitigation plans.
- **Policy engine rules:** Identify which policy engine rules apply to the deployment of this dataset or model.

Complete this template during dataset/model onboarding and update it whenever significant changes occur. Maintaining detailed documentation supports transparency, reproducibility and compliance with NAP’s supply chain security requirements.


