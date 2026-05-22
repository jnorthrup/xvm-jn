# java2x — Java → X Toolchain

One-button converter + RLM pipeline + Pijul CRDT tracking + axiom validation.

## Quick Start
  bash java2x.sh --module myapp /path/to/java-src /path/to/output
  xtc build axioms/ax.x -L <xdk-lib>

## Files
  java2x.sh         — one-button converter
  RLM.md            — RLM workflow
  AXIOMS.md         — validated per-statement invariants
  PARAMETERIZATION.md — reparameterization guide
  axioms/           — xtc test suite (24 invariants)
  pijul-chain/      — Pijul CRDT patch exports
  relaxf-ref/       — reference port output
