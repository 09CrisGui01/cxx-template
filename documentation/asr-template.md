# ASR template

**Purpose:** a lightweight template for architecturally significant requirements (ASRs). An ASR is
a requirement, usually a quality attribute or constraint, that shapes the architecture and would be
expensive to change later. Use an ASR for those, not for ordinary functional requirements. The
design choices that satisfy an ASR are recorded as [ADRs](adr-template.md).

Copy this file to `documentation/architecture/requirements/NNNN-short-title.md`, using the next
unused number, fill it in, and add the record to the [documentation index](index.md).

---

# ASR NNNN: Title

- **Status:** Proposed | Accepted | Superseded by ASR NNNN | Deprecated
- **Date:** YYYY-MM-DD
- **Verification status:** Met | Partially met | Not met | Not yet verified

## Context

Why this requirement exists, where it comes from (stakeholder, specification section, incident) and
which forces shape it. State facts, and say which were verified.

## Requirement

One testable statement ("The system MUST ..."), with the quality attribute it belongs to and a
measurable acceptance criterion.

## Verification

How the requirement is checked (test, CI job, inspection), what was actually run, the result, and
what is not yet verified.

## Alternatives considered

Other formulations or thresholds of this requirement and why they were not chosen.

## Consequences and trade-offs

What the requirement forces on the design, what it costs, and what must be revisited and when.

## Related decisions

ADRs and ASRs that satisfy, depend on or conflict with this record.
