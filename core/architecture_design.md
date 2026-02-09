# Architecture and Design Guidance

NASA stresses that the quality and longevity of a software‑reliant system are primarily determined by its architecture and design. A well‑structured architecture formalises subsystem decomposition, defines dependencies, provides a basis for evaluating changes and documents valid modes of operation. This section outlines how to translate requirements into a robust architecture and design.

## Architectural principles

1. **Modularity and encapsulation.** Decompose the system into modules or services with well‑defined responsibilities and interfaces. Modules should hide internal details and expose only what is necessary. Modularity supports maintainability, testability and independent verification.
2. **Separation of concerns.** Separate control logic from computation, user interface from business logic and safety functions from non‑safety functions. This separation facilitates independent assurance review.
3. **Clear data flow and interfaces.** Define how data moves between modules. Interfaces should be explicit, typed and validated at boundaries. For safety‑critical systems, ensure that interfaces include sanity checks and error handling.
 For API and message interfaces, provide **schema versions** to manage evolution. Versioned schemas enable backward‑compatible changes and prevent accidental breaking changes in inter‑service communication.
4. **Deterministic behaviour.** Avoid unpredictable execution patterns such as unbounded concurrency, uncontrolled recursion or dynamic memory allocations. Bounded loops and simple control flow are recommended to support analysis and verification.
 Determinism is **mandatory** for safety‑critical partitions (Class 3–4 tasks or autonomy tiers A3–A4). In non‑critical partitions (e.g., AI orchestration), concurrency and dynamic behaviour may be necessary. Design those partitions to isolate non‑determinism and bound resource usage.
5. **Fault tolerance and redundancy.** Identify single points of failure and provide redundancy or graceful degradation, especially for Class 3–4 tasks. At least two independent hazard controls should be implemented for critical hazards.

## Architecture documentation

1. **Context diagram.** Create a high‑level diagram showing the system boundaries, external actors and major subsystems. Identify data flows, communication protocols and security boundaries.
 For Class 2 and above, include a **threat model** and **trust boundary analysis** that identifies potential attackers, threat vectors and mitigations. Document where sensitive data crosses boundaries and how it is protected.
2. **Module decomposition.** Provide a hierarchical decomposition of the system into modules or services. For each module, describe its purpose, interfaces, dependencies and key constraints.
3. **Interface definitions.** Document the inputs, outputs, protocols and error conditions for each interface. For APIs, provide message schemas and describe how invalid inputs are handled.
4. **Architecture rationale and trade studies.** Record design decisions, trade‑offs and alternatives considered. NASA requires projects to perform architecture reviews for major projects; include rationale and criteria used to select the final design.
5. **Mapping to requirements and hazards.** Trace each requirement to the modules that implement it and annotate modules that implement hazard controls. This mapping supports bidirectional traceability.

## Design guidelines

1. **Detailed design specifications.** For each module, define algorithms, data structures and control flow. Use pseudo‑code or flowcharts where appropriate. Follow the coding guidelines in `core/coding_guidelines.md` to limit complexity (e.g., small functions, bounded loops and limited pointer use).
2. **Error handling and assertions.** Define how the system reacts to invalid inputs, resource exhaustion and unexpected states. Assert invariants at module boundaries. Assertions should be side‑effect free and trigger safe error handling when they fail.
 In **safety‑critical partitions**, assertions (or equivalent invariant checks) must not be compiled out for performance reasons. If assertions cannot run in production, provide a validated alternative such as runtime checks or monitor agents.
3. **Security and privacy by design.** Incorporate security requirements, such as authentication, authorisation, data encryption and access controls, into the design. Follow the principle of least privilege and data‑minimisation.
4. **Scalability and performance.** Consider performance requirements and concurrency. Use bounded resources and avoid unbounded recursion or heap allocation where possible. For multi‑threaded code, design to avoid deadlocks and race conditions.
5. **Design for testability.** Provide hooks or dependency injection to allow unit testing in isolation. Avoid hidden dependencies and global state.

### Criticality partitions and domain‑specific tailoring

AI agent systems integrate components of varying criticality. Some modules directly control hardware, enforce hazard controls or support safety‑critical operations, while others perform auxiliary functions such as logging, user interface management or AI inference. To manage this diversity without imposing unnecessary restrictions on non‑critical parts, NAP advocates **criticality partitions**:

1. **Identify criticality levels.** Assign each module or service a criticality level based on the risk and autonomy classification (see `core/risk_classification.md` and `core/risk_autonomy_matrix.md`). For example, Class 3–4 tasks in autonomy tiers A3–A4 are safety‑critical, while Class 0 tasks or autonomy tier A0 may be non‑critical.
 Note that high-autonomy high-risk combinations (e.g., Class 3–4 with autonomy tier A4) are safety-critical and require exceptional controls. Consult the `core/risk_autonomy_matrix.md` to determine authoritative mappings. Do not assume lower risk classes are safe simply because autonomy is high or vice versa.

2. **Partition architecture.** Group modules with similar criticality levels into separate processes, containers or microservices. Safety‑critical partitions should be isolated from less critical partitions through strict interface definitions and secure communication channels. Use hardware or OS‑level isolation (e.g., separate CPUs or containers) where feasible.

3. **Tailor coding rules.** Apply the strictest coding guidelines to safety‑critical partitions, enforcing deterministic control flow, no dynamic memory after initialisation and limited pointer usage (`core/coding_guidelines.md`). For AI runtime or orchestration partitions, permit dynamic memory and asynchronous operations but bound their use and enforce resource limits. Document which rules apply to each partition.
 Examples of **bounding dynamic memory** include setting explicit heap size limits, limiting queue depths and specifying maximum retry counts or timeouts for asynchronous calls. Instrument and monitor usage to detect leaks or unbounded growth.

4. **Define safety interfaces.** Interfaces between partitions must be explicit, typed and validated. Safety‑critical partitions must verify inputs from non‑critical partitions and never rely on non‑critical modules to enforce safety. For example, an AI module may recommend an action, but a deterministic safety controller (in a critical partition) must check whether the action is within safe bounds before executing it (`safety/runtime_behavioral_contracts.md`).

5. **Confidence does not grant authority.** High model confidence or reliability does not justify bypassing safety partitions or controls. Even highly confident predictions must pass through the same autonomy and safety gates as less confident ones. The risk and autonomy classification, not the model’s confidence score, determines authority to act.

6. **Independent verification.** Critical partitions require independent architecture and design reviews, formal verification or model‑checking. Non‑critical partitions may undergo lighter reviews. Document the assurance evidence for each partition and include it in the trace graph (`core/trace_graph_schema.md`).

By implementing criticality partitions, the architecture balances rigorous safety assurance for high‑risk modules with flexibility and performance for less critical components. This approach mirrors aerospace practices where avionics software is partitioned by Design Assurance Level and helps maintain developer productivity without compromising safety.

## Designing hybrid deterministic and probabilistic systems

Modern agent architectures often combine deterministic control logic with probabilistic AI components such as large language models (LLMs) and machine learning classifiers. This hybrid nature introduces unique design considerations:

1. **Isolation and encapsulation of AI modules.** Encapsulate AI models behind well‑defined service interfaces. Do not embed model inference directly into mission‑critical logic; instead, call AI services and handle their outputs explicitly.
2. **Explicit uncertainty handling.** Design interfaces to propagate uncertainty estimates alongside predictions. Downstream modules should interpret these estimates and decide whether to act autonomously, seek human approval or defer.
3. **Graceful degradation.** Implement fallback strategies when AI predictions are unavailable, uncertain or unsafe. For example, revert to rule‑based behaviour, prompt a human operator or abort the operation.
4. **Asynchronous and event‑driven patterns.** AI inference may be computationally intensive and slower than deterministic logic. Use asynchronous messaging, event queues or microservice patterns to decouple timing. Ensure timeouts and retry policies are defined.
5. **Monitoring hooks.** Include instrumentation to collect metrics on AI module performance (e.g., accuracy, latency, drift indicators). Connect these to continuous evaluation pipelines (see `safety/ai_specific_considerations.md`).
6. **Fail‑safe boundaries.** Clearly define boundaries where deterministic logic takes over to enforce safety constraints. For example, an AI system may recommend a trajectory, but a deterministic safety controller should verify the trajectory before executing it.

## Architecture and design review

1. **Independent review.** Conduct architecture and design reviews with participants who were not involved in the initial design. NASA requires such reviews for major projects. Review checklists should include compliance with requirements, hazard controls, coding guidelines and performance goals.
 Record the outcome in an **Architecture Review Record (ARR)** artifact. The ARR should list attendees, findings, action items and sign‑offs, and be stored in the configuration management system.
2. **Prototyping and simulation.** For complex components, develop prototypes or models to validate design assumptions. Validate the design on a high‑fidelity simulation or the target platform before committing to full implementation.
3. **Update documentation.** Incorporate review feedback into the architecture documents and ensure that all changes are captured in the configuration management system.

## Linking to other sections

* **Requirements management:** Use validated requirements from `core/requirements_management.md` as the basis for architectural decomposition. Ensure each requirement is addressed in the architecture and design.
* **Risk classification:** Risk classes defined in `core/risk_classification.md` inform the level of rigor needed in architectural documentation and review. Class 3–4 tasks require formal architecture reviews and hazard controls.
* **Coding guidelines:** Implement the design following the coding rules and safety restrictions in `core/coding_guidelines.md` to ensure implementability and maintainability.
* **Testing and verification:** Create test plans and coverage goals in `safety/testing_and_verification.md` that align with the architectural modules and interfaces. The architecture should make it easy to isolate modules for testing.
* **Safety and assurance:** Identify safety‑critical modules and hazard controls in the architecture and coordinate with `safety/safety_and_assurance.md` to ensure appropriate redundancy and verification.

By investing time in architecture and design, projects can prevent costly downstream changes, enable rigorous analysis and meet NASA’s high expectations for software quality and safety.



