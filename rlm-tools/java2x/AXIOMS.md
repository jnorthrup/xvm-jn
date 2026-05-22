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

## Semantic Gap: java2x.sh produces Java-with-X-skin

The converter handles syntax (instanceof→.is, (T)x→x.as(T), static{}→construct).
But the output still has JDBC/HttURLConnection/Gson patterns that must be
replaced with relaxf-ref CouchDriver fluent API.

## jdbc2json RLM audit (2026-05-21)

Converted output has these Java patterns that RLM doesn't handle:

```
/tmp/port/jdbc2json/server/BatchBuild.x:10: public static GsonBuilder BUILDER
/tmp/port/jdbc2json/server/BatchBuild.x:12: public static Gson GSON = BUILDER.create()
/tmp/port/jdbc2json/server/BatchBuild.x:37: DRIVER = DriverManager.getDriver(jdbcUrl)
/tmp/port/jdbc2json/server/BatchBuild.x:43: ResultSetMetaData metaData1
/tmp/port/jdbc2json/server/BatchBuild.x:44: try (var resultSet = DRIVER.connect(...).createStatement().executeQuery(sql))
/tmp/port/jdbc2json/server/BatchBuild.x:73: HttpURLConnection httpCon = url.openConnection().as(HttpURLConnection)
```

Gap identified (POST-STRATEGY FIX):
1. **Gson/GsonBuilder** → KEEP via X context adapter (javap reflection wrapper)
2. **HttpURLConnection PUT** → use CouchDriver.DbCreate/DocPersist/JsonSend (async NIO)
3. **JDBC (ResultSet/Statement/Connection)** → KEEP via javatools bridge, wrap in X adapter

**Strategy**: Non-portable Java jars wrapped in X context adapters.
- Thunking overhead acknowledged (Java↔X boundary)
- Developers mitigate by coarser-grained calls later
- Shims carried as .x files calling Java via reflection

Current status: RLM produces syntactic X + Java adapters. Core X logic via CouchDriver,
data access via Java shims with known performance costs.

## RLM Loop — Full Steps

```bash
# 1. Fresh clone
git clone --depth=1 --branch latest_java https://github.com/jnorthrup/jdbc2json

# 2. Record — convert fresh each time
bash lib_relaxf/java2x/java2x.sh --module jdbc2json \
  /tmp/jdbc2json/src/main/java /tmp/port

# 3. Learn — compile only, no auto-fix
cd /tmp/port && xtc build x_jdbc2json.x

# 4. Audit — diff vs relaxf-ref patterns
#    find Java patterns (above) → replace with CouchDriver builders

# 5. Migrate — re-port fresh after fixes
rm -rf /tmp/port
bash lib_relaxf/java2x/java2x.sh --module jdbc2json \
  /tmp/jdbc2json/src/main/java /tmp/port
```

Rule: re-port fresh each run. Never patch incrementally.

## Relaxf-ref CouchDriver API (target pattern)

```x
# Create DB
CouchDriver.DbCreate.$().db("mydb").to().fire().tx()

# Persist doc
CouchDriver.DocPersist.$().db("mydb").docId("id").validjson(json).to().fire().tx()

# Fetch doc
CouchDriver.DocFetch.$().db("mydb").docId("id").to().fire().json()

# Query view
CouchDriver.ViewFetch.$().db("mydb").view("design/doc").to().fire().rows()

# Send raw
CouchDriver.JsonSend.$().opaque("path").validjson(json).to().fire().json()
```

## Result: Three classes of RLM errors exist.

1. Module filename collision (RelaxFactory finding, 2026-02)
2. for-loop condition truncation (AX-RLM-1, jdbc2json 2026-05) — OBSOLETE, xtc now accepts Java syntax
3. instanceof→cast cascade corruption (AX-RLM-2, jdbc2json 2026-05) — OBSOLETE, xtc accepts both
