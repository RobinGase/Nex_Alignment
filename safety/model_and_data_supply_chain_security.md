# Model and Data Supply Chain Security

AI systems rely on complex supply chains that include datasets, pre‑trained models, software libraries and cloud services. The NIST Generative AI profile warns that generative AI value chains involve numerous third‑party components that may be improperly obtained or not vetted, reducing transparency and accountability. The NIST AI Risk Management Framework emphasises that robust metadata, versioning, provenance and bias notes are essential for AI‑ready datasets. This document outlines practices for ensuring the integrity and security of data and model supply chains within the **NexGentic Agents Protocol (NAP)**.

## Dataset provenance and documentation

1. **Record provenance metadata.** For each dataset version, record the origin (e.g., sensor, public dataset, synthetic generator), ownership, licensing terms and any transformations applied. The NIST guidance on provenance metadata notes that it should capture origin, ownership, transformations and usage.
2. **Version and release notes.** Assign a version identifier to every dataset release. Maintain release notes describing changes (new samples, corrections, label updates) and maintain a relationship between versions so that users can trace dataset history. Document the release date and decommissioning date where applicable.
3. **Bias notes and quality status.** Record potential biases, sampling limitations and quality assessment results for each dataset. Guidance from UK AI‑ready dataset standards recommends including bias notes, provenance and ML‑oriented metadata.
4. **Digital signatures and tamper evidence.** Sign dataset metadata and artefacts with cryptographic signatures. NIST states that provenance metadata can be cryptographically signed to ensure authenticity and tamper evidence. Include checksums or digital signatures in release packages and verify them during ingestion.
5. **Software bill of materials (SBOM) for datasets.** Maintain a SBOM that lists data sources, scripts, dependencies and version numbers used to create the dataset. Update the SBOM whenever the data pipeline changes.
 The dataset SBOM SHOULD include, at a minimum, the following fields: (a) **sources** (URLs or sensors), (b) **transforms** (pre‑processing steps, augmentation scripts and their parameters), (c) **scripts** (names and versions of ETL scripts, notebooks or pipelines), (d) **dependencies** (packages and libraries with versions and checksums), and (e) **hashes/checksums** of the final dataset files. Capturing these elements enables reproducibility and aids forensic analysis.

## Model lineage and security

1. **Model versioning and lineage.** Assign a unique identifier to each model version and record metadata such as training dataset, hyperparameters, architecture, evaluation metrics and lineage (parent model). The NIST documentation draft includes fields for model version ID, signature and lineage. Record whether models were fine‑tuned from third‑party base models and note licensing terms.
 Include an attestation of the **training and runtime environment**: the container or virtual machine digest, hardware class (CPU/GPU type), operating system, key library versions and random seed. This attestation supports reproducibility and supply‑chain integrity.
2. **Model signing and verification.** Sign model artefacts and metadata using digital signatures, as recommended for provenance metadata. Verify signatures before deploying models to ensure integrity and prevent tampering.
3. **Third‑party model vetting.** When using external models, assess their provenance and licensing. Document potential risks such as data contamination, backdoors or adversarial vulnerabilities. The NIST GAI profile highlights that third‑party components may not be vetted and can reduce accountability.
4. **SBOM for models.** Maintain a SBOM that lists model dependencies (libraries, frameworks, pre‑trained weights). Include information on training data sources and any third‑party code integrated into the model pipeline.

## Supply chain risk management and controls

1. **Supplier assessment.** Assess suppliers of datasets, models and libraries for compliance with security, privacy and ethical standards. Include questions about data sourcing, data protection practices and vulnerability management. Conduct periodic reviews and audits.

 For third‑party models or datasets integrated into high‑risk systems, **classify the supplier’s risk class as at least equal to the system’s risk class**. If a supplier cannot meet the required risk class (e.g., a model provider with unknown provenance), then the overall system risk class must be raised or the component must be excluded. Document supplier risk classifications and justification in the risk register.
2. **Secure ingestion workflows.** Define secure processes for acquiring and ingesting data and models. Verify digital signatures, check licensing terms and run security scans on code and data. Use isolated environments to inspect untrusted artefacts before integrating them into production systems.

3. **Poisoning and backdoor detection.** For each dataset and model, assess the risk of data poisoning or hidden backdoors. Apply appropriate detection techniques (e.g., statistical tests, activation clustering, trojan detection tools). Document the methods and results in the supply chain artefacts. If detection is not feasible, record a justification and increase the risk class or apply additional monitoring.
3. **Continuous monitoring.** Monitor for updates, advisories and vulnerabilities in the supply chain. When security issues are disclosed (e.g., compromised dataset, model backdoor), follow change control procedures to patch or replace affected artefacts.
4. **License compliance.** Ensure that usage of third‑party models and datasets complies with their licenses. Document any restrictions on redistribution, modification or commercial use.
5. **Data retention and decommissioning.** Define retention periods for datasets and models. When decommissioning, securely delete or archive artefacts and update metadata to reflect their retired status.

6. **Vendor transparency and certification.** Require suppliers to provide transparency into their training data sources, model architectures, fine‑tuning processes and security practices. When available, prefer vendors that hold recognised certifications (e.g., ISO 27001, SOC 2) or equivalent assurance attestations. If a vendor cannot meet transparency or certification requirements, treat the component as higher risk and apply additional mitigation or avoid using it.

## Linking to other sections

* **Configuration management:** Treat datasets and models as configuration items and manage them according to `core/configuration_and_risk_management.md`. Record provenance, version, signature and SBOM information in the configuration management database.
* **AI‑specific considerations:** `safety/ai_specific_considerations.md` discusses model and data governance, emergent behaviours and drift monitoring. Align supply chain security practices with those considerations.
* **Evidence anchoring:** Cryptographic signatures and checksums complement the tamper‑proof logging and evidence anchoring described in `safety/evidence_anchor_and_log_integrity.md`.
* **Risk management:** Include supply chain risks in the risk register. Third‑party models and data may introduce unknown biases or vulnerabilities that require mitigation and, if necessary, residual risk acceptance (`safety/risk_acceptance_and_residuals.md`).

By establishing comprehensive provenance, documentation and signing practices for datasets and models, NAP mitigates supply chain risks and supports trustworthy AI development and operation. These practices enhance transparency and accountability and align with emerging AI governance standards.



