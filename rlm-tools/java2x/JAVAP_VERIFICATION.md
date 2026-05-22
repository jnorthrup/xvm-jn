# Javap Verification of X-Java Bridges

## Principle

Java is the stricter type system. X is more permissive.
- Use javap (Java disassembler) to verify X-to-Java method calls are valid
- Every .x file that calls Java should be verifiable against Java class signatures
- Checksum: javap output digests = proof of valid bridge

## Verification flow

```bash
# 1. Extract Java method calls from .x
grep -oh '@Inject.*Method' *.x | sed 's/.* //' > java-calls.txt

# 2. javap actual classes to get signatures
javap -public -s com.google.gson.Gson | grep 'public static' > actual-sigs.txt

# 3. Diff: X calls must exist in Java signatures
diff java-calls.txt actual-sigs.txt
```

## RLM integration

Add to java2x.sh:
```bash
# After conversion, verify Java bridges
echo "=== javap verification ==="
for xfile in "$OUT_DIR"/*.x; do
    # Extract @Inject Method signatures
    # Run javap on referenced classes
    # Fail if signature mismatch
done
```

## Why this works

- Java's type system won't lie
- X's `@Inject java.lang.reflect.Method` admits it's calling into Java
- javap gives ground truth: what methods actually exist
- Mismatch = bug in X adapter or Java classpath mismatch

## Benefit

Automated verification that X context adapters actually work.
No runtime "method not found" surprises.
