# Coding Guidelines

Code quality directly influences the reliability, maintainability and safety of a system. This protocol mandates the use of coding standards and static analysis tools to detect defects, assess security and control complexity. The **deterministic safety coding rules**, provide a concise, tool‑checkable standard for safety‑critical C code. This section adapts those rules for general languages and supplements them with secure coding practices.

## Core rules (adapted from the deterministic safety coding rules)

1. **Use simple control flow.** Avoid `goto`, unbounded recursion or complex branching. Do not use `setjmp/longjmp`. Keep loops bounded and predictable. In safety‑critical partitions, loops must have a statically provable upper bound; in non‑critical partitions, unbounded loops are permitted only when they are externally bounded (e.g., event loops with timeout). This ensures that the worst‑case behaviour is analysable.
2. **Bounded loops and recursion.** All loops in safety‑critical partitions must have a fixed upper bound that can be proven statically. Where recursion is necessary, set an explicit depth limit and guard against stack overflows. For AI runtime partitions, apply upper bounds or timeouts to loops and recursion to prevent uncontrolled growth.
3. **Avoid unbounded dynamic memory after initialisation.** In safety‑critical partitions, allocate memory statically or on the stack during initialisation and do not allocate on the heap at runtime. In AI runtime partitions, dynamic allocation may be necessary but must be bounded and predictable (e.g., pre‑allocate pools, set heap size limits and monitor usage).
4. **Keep functions small.** Functions should be short enough to fit comfortably on one printed page (~60 lines). Small functions enhance readability and make it easier to reason about behaviour and perform unit testing.
5. **Use assertions liberally.** Insert assertions to check preconditions, postconditions and invariants. Each **safety‑critical function** must enforce at least one invariant (via assertions or equivalent checks); critical functions should have multiple. Assertions must be side‑effect free and should trigger safe error handling if they fail. For non‑critical code, assertions are recommended but may be compiled out if replacement runtime checks exist and are validated.
6. **Limit variable scope.** Declare variables at the smallest possible scope. Avoid global variables unless they are constant and have a well‑documented purpose.
7. **Check return values and validate parameters.** Always inspect the return values of functions, handle error codes and validate input parameters before use.
8. **Restrict preprocessor and metaprogramming.** Use preprocessor directives (or language equivalents) only for header inclusion and simple macros. Avoid complex macros and conditional compilation because they obscure logic and hinder analysis.
9. **Restrict pointer usage.** Limit pointer indirection to one level where possible; avoid function pointers unless necessary. In languages without pointers (e.g., Python), avoid creating nested references that hamper readability.
10. **Compile with all warnings enabled and fix them.** Treat compiler and static analysis warnings as errors. Use multiple static analysis tools to detect defects early and run them as part of the verification process.

### Safety‑critical versus AI runtime code

The deterministic safety coding rules were designed for embedded C code in safety‑critical systems. AI agents may include both safety‑critical components (e.g., hardware control, hazard mitigation) and AI runtime components (e.g., LLM orchestration, data pre‑processing). Apply stricter restrictions to safety‑critical code: avoid dynamic memory after initialisation, limit recursion and pointer usage, and enforce deterministic control flow. In AI runtime components, dynamic memory and asynchronous operations may be necessary but should be bounded, managed deterministically and isolated from safety‑critical logic. Document which modules are safety‑critical and apply the appropriate subset of these coding rules. The architecture should enforce criticality partitions (`core/architecture_design.md`) so that AI runtime modules cannot compromise safety‑critical modules. Use interface validators and runtime behavioural contracts (`safety/runtime_behavioral_contracts.md`) to ensure that actions recommended by AI modules stay within safe boundaries.

## Additional secure coding practices

1. **Follow language and project‑specific style guides.** Adhere to established conventions (e.g., PEP 8 for Python) to improve readability. Document naming schemes, indentation and file organisation.
2. **Immutable data and pure functions.** Where possible, use immutable data structures and pure functions (without side effects). This reduces complexity and facilitates reasoning about state.
3. **Input validation and sanitisation.** Treat all external inputs as untrusted. Validate types, ranges and formats. Sanitize strings to prevent injection attacks and command execution.
4. **Error handling and exceptions.** Handle errors explicitly. In languages with exceptions, catch specific exceptions and avoid blanket catches. Never suppress errors silently.
5. **Resource management.** Use language‑supported mechanisms (e.g., context managers in Python, RAII in C++) to release resources deterministically. Avoid memory leaks and file handle leaks.
6. **Concurrency safety.** For multi‑threaded applications, use synchronisation primitives correctly and avoid deadlocks. Prefer immutable data and message passing over shared mutable state.
7. **Secure by design.** Follow the principle of least privilege: agents should only access resources they need. Encrypt sensitive data at rest and in transit. Avoid storing secrets in code repositories.
8. **Internationalisation and data formats.** Handle character encodings (UTF‑8) properly. Avoid locale‑dependent parsing. Use standard data formats (e.g., JSON, XML) and avoid ad‑hoc parsers.

9. **Dependency pinning and SBOMs.** Pin dependency versions and maintain a **software bill of materials (SBOM)** to track third‑party packages and their versions. Use tools to generate SBOMs and verify them against trusted sources. Align with supply chain security guidance (`safety/model_and_data_supply_chain_security.md`).

## Static analysis and complexity metrics

1. **Static analysis.** Employ static analysis tools to detect bugs, security vulnerabilities and complexity hotspots. This protocol requires static analysis to be used during development and testing. Document tool configurations and results.
2. **Complexity metrics.** Measure cyclomatic complexity, function length and number of parameters. Set thresholds to flag refactoring candidates. High complexity functions should be split into smaller units.
 Use policy‑defined constants or project configuration to set thresholds (e.g., maximum cyclomatic complexity = 10, maximum function length = 60 lines). Document these thresholds and adjust them based on domain and risk class.
3. **Code reviews.** Require code reviews by peers or independent reviewers before merging changes. Reviewers should check for adherence to these guidelines, correctness and security considerations.

## AI‑specific implementation considerations

AI agent systems often integrate machine learning models, asynchronous pipelines and dynamic data flows. While the deterministic safety coding rules provide a solid baseline for safety‑critical code, some adaptations are necessary:

1. **Dynamic memory and resource management.** AI frameworks may allocate memory dynamically (e.g., for model inference). Restrict dynamic allocation to initialisation or clearly bounded contexts. Release resources deterministically (e.g., using context managers in Python or RAII in C++). Avoid memory leaks by testing under heavy load.
2. **Asynchronous operations and event loops.** Use asynchronous programming (async/await, promises, event loops) for I/O‑bound model inference or API calls. Ensure that timeouts, retries and cancellation mechanisms are implemented to avoid deadlocks or runaway tasks. Limit the number of concurrent operations to prevent resource exhaustion.
3. **Model orchestration.** When orchestrating multiple models (e.g., an LLM combined with a classifier), encapsulate each model call in its own function or service. Validate inputs and outputs at each step, and handle exceptions gracefully.
4. **Configuration of AI models.** Load model weights and configuration parameters from version‑controlled artifacts. Do not hard‑code secrets or rely on mutable global state. Document model version and training data lineage.
5. **Logging and observability.** Implement structured logging around model inference, capturing inputs (excluding sensitive data), outputs, confidence scores and latencies. These logs support monitoring for drift and unexpected behaviours (`safety/ai_specific_considerations.md`).
6. **Safeguards against prompt injection and adversarial inputs.** Validate and sanitise prompts provided to generative models. Consider rate limiting, input validation and output filtering to prevent misuse or injection attacks. Align with OWASP recommendations for AI security.

7. **Output handling and tool invocation.** Do not execute code, tool calls or system commands derived directly from model outputs without validation. Treat model responses as untrusted data. Validate and sanitise any generated commands or file paths before execution. Use whitelists and heuristics to detect unsafe operations and enforce human approval for high‑risk actions.

These AI‑specific guidelines supplement the core coding standards to accommodate dynamic, event‑driven and probabilistic components while maintaining safety, reliability and maintainability.

## Linking to other sections

* **Architecture and design:** Apply these guidelines when refining the design into code. The architecture should facilitate small, independent modules that adhere to the coding rules (`core/architecture_design.md`).
* **Testing and verification:** Unit tests and static analysis results must be recorded in the verification log (`safety/testing_and_verification.md`). Code coverage metrics help verify that functions of all complexity levels are exercised.
* **Risk classification:** Higher risk classes (Class 2–4) require stricter adherence to the deterministic safety coding rules and more rigorous static analysis. For Class 3–4 tasks, avoid dynamic memory entirely and restrict pointer use as much as possible.
* **Safety and assurance:** Assertions and error handling form part of the safety controls. Document how code conforms to safety guidelines and hazard mitigations (`safety/safety_and_assurance.md`).

Following these coding guidelines reduces defects, improves maintainability, and aligns with rigorous standards for safety-critical software.





