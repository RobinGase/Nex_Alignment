# Evidence Anchoring and Log Integrity

Ensuring the integrity and authenticity of evidence is vital for accountability in high‑risk systems. Logs, hazard logs, test reports and configuration records may be used in audits, hazard investigations or legal proceedings. NIST notes that provenance metadata can be cryptographically signed, providing tamper evidence and enabling verification of integrity via checksums or digital signatures. This document describes practices for anchoring evidence and securing logs within the **NexGentic Agents Protocol (NAP)**.

## Why evidence anchoring?

* **Tamper detection.** Cryptographic signatures detect unauthorised modifications to logs and artefacts. If a log entry is altered, the signature becomes invalid, signalling potential tampering.
* **Chain of custody.** Anchoring ensures that documents remain authentic across transfers and over time, providing a verifiable chain of custody for audits and investigations.
* **Trust in AI decisions.** For AI systems, evidence of decisions, inputs and outputs must be immutable to assess compliance with requirements, ethical standards and risk acceptance decisions.

## Anchoring mechanisms

1. **Digital signatures.** Sign logs, hazard logs, test reports, risk acceptance forms and configuration baselines using asymmetric cryptography. Store public keys in a trusted key management system. Verify signatures during reviews and audits. NIST emphasises that cryptographically signing metadata ensures authenticity and tamper evidence.
2. **Hash chains.** Create a hash chain where each log entry includes a hash of the previous entry. This technique, similar to blockchain, links entries into an immutable sequence. Altering any entry breaks the chain.
3. **Time‑stamped receipts.** Use a trusted timestamp authority to issue time‑stamped signatures for important events (e.g., deployment, risk acceptance). This proves that evidence existed at a specific time.
4. **Merkle trees for artefact sets.** When producing a release or baseline containing multiple artefacts, compute a Merkle tree root hash and sign it. This allows verification of individual artefacts without re‑signing the entire set.
5. **External notarisation and trusted timestamps.** Anchor important evidentiary artefacts (e.g., risk acceptance forms, release packages) to an external notarisation or timestamp service. For example, publish the Merkle root hash or signed evidence digest to a public blockchain or submit it to a trusted time‑stamping authority. External anchoring provides an independent, immutable timestamp that cannot be altered by the organisation and strengthens auditability.
6. **Secure storage and access control.** Store logs and signatures in secure, access‑controlled repositories. Limit write access to authorised processes and enforce read‑only access for archived logs. Off‑site backups and replication protect against data loss.

### Cryptographic algorithms

Select cryptographic algorithms that meet or exceed the organisation’s security policy (e.g., **NIST FIPS 140‑3** compliance). At minimum, use widely‑accepted hashing algorithms (e.g., **SHA‑256** or **SHA‑3**) and signature schemes (e.g., **ECDSA** with P‑256 or Ed25519 keys). Avoid deprecated algorithms (e.g., MD5, SHA‑1). Document the chosen algorithms and key sizes in the configuration management system and update them in response to cryptographic deprecation.

## Evidence anchoring workflow

1. **Generate log entry.** When an event occurs (e.g., test execution, hazard control verification), record the log entry with metadata (timestamp, actor, description, IDs).
2. **Compute hash and sign.** Compute a hash of the entry and sign it with a private key. Append the signature and, if using a hash chain, include the hash of the previous entry.
3. **Store securely.** Write the signed entry to the log and replicate it to secure storage (e.g., append‑only file system or blockchain). Store copies off‑site for redundancy.
4. **Verify on read.** When retrieving logs, verify signatures and hash chains. Tools should alert if verification fails.
5. **Anchor to risk acceptance and traceability.** Link log entries to traceability IDs (e.g., `TST-#`, `CTL-#`, `RIS-#`) and include them in risk acceptance forms (`safety/risk_acceptance_and_residuals.md`).

6. **Generate reproducibility packages.** When releasing software or models, generate a reproducibility package that bundles the artefacts, metadata, configuration settings, environment descriptors and dataset pointers used to produce the release. Sign the package manifest and include it in the evidence anchor. Reproducibility packages enable external auditors or regulators to replicate results and verify compliance.

## Linking to other sections

* **Configuration management:** Evidence anchoring complements configuration management by protecting the integrity of CIs and logs (`core/configuration_and_risk_management.md`).
* **Traceability:** Use anchor IDs within the trace graph to ensure that test results and hazard controls cannot be tampered with (`core/traceability_and_documentation.md`).
* **Risk acceptance:** Signed evidence strengthens residual risk acceptance decisions and protects them against later disputes (`safety/risk_acceptance_and_residuals.md`).
* **Supply chain security:** Use similar signing approaches for datasets and models as described in `safety/model_and_data_supply_chain_security.md`.

By adopting cryptographic evidence anchoring and log integrity mechanisms, NAP ensures that artefacts remain trustworthy throughout the life cycle. These techniques support accountability, facilitate audits and help establish confidence in the safety and compliance of AI systems.



