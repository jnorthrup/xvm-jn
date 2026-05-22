# RLM: The Java→X Pipeline

RLM = Record → Learn → Migrate. Three-phase port tracked in Pijul CRDT.

## Phase 1: Record

```bash
cd /path/to/java
pijul init && pijul add -r . && pijul record -a -m "initial"
```

## Phase 2: Learn

```bash
# Validate the 24 axioms against your xtc version
xtc build java2x/axioms/ax.x -L <xdk-lib>
```

The hard lesson: ALL Java syntax is accepted by xtc as-is. Only the
module filename collision (module.x + module/ dir) causes real errors.

## Phase 3: Migrate

```bash
bash java2x.sh --module myapp /path/to/java /path/to/x-output
```

12 transforms run across every .java file:
1. Strip: package, import, private, protected, final, throws
2. Strip: synchronized, native, transient, volatile, strictfp
3. Strip: @SuppressWarnings
4. Convert: assert → assert:test
5. Types: boolean/multi/int/long/byte/short/float/double/char/null → XLang
6. Casts: (Type) expr → expr.as(Type)
7. Array init: {a,b} → [a,b]
8. Wildcards: remove <?> and <>
9. Constructor: Name(params) → construct(params)
10. Static init: static {} → static construct() {}
11. Remove super()
12. instanceof → .is()

## RLM loop

```bash
while xtc build fails; do
    read FIRST error only
    fix that ONE error
    rebuild
done
```

## Pijul deltas

Three patches in pijul-chain/:
- 000-initial: raw Java source
- 001-restructure: cone-shaped layout (98 hunks)
- 002-syntax-transform: 12 regex transforms (1050 hunks)
