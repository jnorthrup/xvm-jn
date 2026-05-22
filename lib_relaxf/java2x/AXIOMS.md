# Java→X Conversion: Validated Axioms
Status: each invariant tested against xtc compiler.
Suite: /tmp/xtc-ax/test/AllAxioms.x

## Module filename collision (sole root cause of all RLM errors)

relaxf.x + relaxf/ directory → PARSER-03 on every file
  mod.x  + relaxf/ directory → CLEAN BUILD

The module file name colliding with a sibling directory causes xtc to parse
it as source code inside that package. Fix: rename module file with prefix.

## Per-File Axioms

F1: One type per file in sub-package mode — REQUIRED
F2: package declaration — OPTIONAL in cone-shaped layout
F3: import statements — WORK
F4: file-level annotations — WORK
F5: static {} || static construct() {} — BOTH WORK
F6: private/protected/final — ALL WORK

## Per-Project Axioms

P1: No reflection — NOT TESTED (no Class.forName in RelaxFactory)
P2: No dynamic class loading — NOT TESTED
P3: JDK API bridgeable via javatools — VALIDATED
P4: No GWT runtime dependency — ASSUMED
P5: Single module, no cycles — VALIDATED
P6: Single-threaded NIO model — ASSUMED

## Per-Statement Axioms — xtc-validated

S1: instanceof AND .is() — BOTH FIRST-CLASS (instanceof in keyword table)
S2: (Type)expr AND expr.as() — BOTH ACCEPTED (as() in spec, cast is permissive)
S3: class(params){} AND construct(params){} — BOTH VALID
S4: private/final AND bare — ALL ACCEPTED
S5: throws AND bare — BOTH ACCEPTED
S6: interface AND service — BOTH VALID, DIFFERENT SEMANTICS
S7: for(T x : c) — IDENTICAL
S8: try/catch/finally — IDENTICAL
S9: new T(){body} — IDENTICAL (assignment AND method call)
S10: boolean/Boolean, int/Int, null/Null — ALL ACCEPTED
S11: String, Object — IDENTICAL
S12: {a,b} AND [a,b] arrays — BOTH ACCEPTED

## Result: Three classes of RLM errors exist.

1. Module filename collision (RelaxFactory finding, 2026-02)
2. for-loop condition truncation (AX-RLM-1, jdbc2json 2026-05)
3. instanceof→cast cascade corruption (AX-RLM-2, jdbc2json 2026-05)
