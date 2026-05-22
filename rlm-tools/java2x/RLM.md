# RLM: Record → Learn → Migrate

Three-phase port loop tracked in Pijul CRDT. NOT a one-shot converter.

## The RLM Loop

```
cd /src
bash java2x.sh --module myproj src/ out-x/    # Phase 1: Record
                                           # Phase 2: Learn
cd out-x && xtc build x_myproj.x 2>&1        # compile only (no auto-fix)
                                           # Phase 3: Migrate
# audit: diff output vs relaxf-ref pure X patterns
# fix java2x.sh transforms
# bash java2x.sh --module myproj src/ out-x/  # re-port fresh each iteration
```

**Rule: re-port fresh each run. Never patch incrementally.**

## What the converter produces

java2x.sh is a regex pipeline that produces **Java-with-X-skin**:
- compiles with xtc (Java syntax accepted)
- still has instanceof, C-casts, Gson, HttpURLConnection, SQLException
- NOT pure X — needs hand-audit vs relaxf-ref

## Pure X baseline (relaxf-ref)

From lib_relaxf/java2x/relaxf-ref/relaxf/:
- HttpMethod, HttpHeaders, HttpStatus, MimeType — NIO HTTP stack
- CouchDriver — DbCreate/DocPersist/JsonSend builders with .fire().tx()
- DbKeysBuilder → ActionBuilder → TerminalBuilder chain
- DocFetch/DocDelete/ViewFetch all via fluent $.db().docId().to().fire().json()
- NO Gson, NO HttpURLConnection, NO SQLException

## Known conversion gaps (must fix in RLM)

| Java | X | Status |
|------|---|--------|
| instanceof | .is() | converter does regex but X also accepts instanceof |
| (Type)expr | expr.as(Type) | same — both accepted |
| static {} | static construct() {} | works |
| new Type[] {a,b} | [a,b] | works |
| null | Null | works |
| int | Int | works |
| boolean | Boolean | works |

The converter handles syntax. The gap is **semantic**: the converted code still
has JDBC + HttpURLConnection patterns that must be replaced with the relaxf-ref
CouchDriver fluent API.

## RLM Steps

1. `git clone --depth=1 --branch latest_java https://github.com/jnorthrup/jdbc2json`
2. `bash java2x.sh --module jdbc2json /path/to/src /tmp/port`
3. `cd /tmp/port && xtc build x_jdbc2json.x` — expect clean (syntax ok)
4. Audit vs relaxf-ref: find JDBC/HttURLConnection/Gson usage → replace with CouchDriver builders
5. Fix java2x.sh or write CouchDriver wrappers to fill the gap
6. Delete /tmp/port, re-run from step 2

## Module filename rule

Module file must NOT collide with sibling directory:
- `relaxf.x` + `relaxf/` → PARSER-03 on every file
- `x_relaxf.x` + `relaxf/` → CLEAN BUILD
- java2x.sh prefixes with `x_` to avoid this.