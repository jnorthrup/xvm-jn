#!/bin/bash
# java2x  — one-button Java → X conversion
# Input:  directory of .java files
# Output: cone-shaped X project that compiles with `xtc build`
# See: java2x-conversion skill for full documentation

set -euo pipefail

ME=$(basename "$0")
usage() { echo "Usage: $ME [--module NAME] [--lib PATH] <src-dir> [out-dir]"; exit 1; }

MODNAME=""; LIBS=""; VERBOSE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --module) MODNAME="$2"; shift 2 ;;
        --lib)    LIBS="$LIBS -L $2"; shift 2 ;;
        -v)       VERBOSE=true; shift ;;
        -h) usage ;; *) break ;;
    esac
done
SRC_DIR="${1:?Missing source directory}"
OUT_DIR="${2:-$(basename "$SRC_DIR")-x}"
[[ -d "$SRC_DIR" ]] || { echo "Error: $SRC_DIR not a directory"; exit 1; }

# Discover Java sources
JAVA_FILES=()
while IFS= read -r f; do JAVA_FILES+=("$f"); done < <(find "$SRC_DIR" -name '*.java' -not -path '*/test/*' -not -path '*/build/*' 2>/dev/null | sort)
[[ ${#JAVA_FILES[@]} -gt 0 ]] || { echo "Error: no .java files found"; exit 1; }
$VERBOSE && echo "Found ${#JAVA_FILES[@]} Java files"

# Module name
[[ -z "$MODNAME" ]] && MODNAME=$(basename "$SRC_DIR" | sed 's/[^a-zA-Z0-9]/_/g' | tr '[:upper:]' '[:lower:]')
MODNAME=$(echo "$MODNAME" | sed 's/-/_/g')
# Module filename MUST NOT collide with package directory — prefix with x_
MODFILE="x_${MODNAME}.x"
TOP_PKG="$MODNAME"
$VERBOSE && echo "Module: $MODNAME -> $MODFILE"

# Cone-shaped output layout
rm -rf "$OUT_DIR"
XDIR="$OUT_DIR/$TOP_PKG"
mkdir -p "$XDIR/server" "$XDIR/rsync" "$XDIR/couch"

# Package dir mapping
map_pkg_dir() {
    case "$1" in
        one/xio)         echo "$XDIR" ;;
        rxf/server*)     echo "$XDIR/server" ;;
        rxf/rsync*)      echo "$XDIR/rsync" ;;
        rxf/couch*)      echo "$XDIR/couch" ;;
        *)               echo "$XDIR/server" ;;
    esac
}

# Python transform pipeline
for java in "${JAVA_FILES[@]}"; do
    rel="${java#$SRC_DIR/}"
    dir=$(dirname "$rel")
    base=$(basename "$java" .java)
    xdir=$(map_pkg_dir "$dir")
    mkdir -p "$xdir"
    xfile="$xdir/${base}.x"
    $VERBOSE && echo "  $rel → ${xfile#$OUT_DIR/}"

python3 -c "
import re, sys
with open('$java') as f: c = f.read()

# === Strip Java boilerplate ===
c = re.sub(r'^package\s+[\w.]+\s*;\s*\n', '', c, flags=re.MULTILINE)
c = re.sub(r'^import\s+(static\s+)?[\w.*]+\s*;\s*\n', '', c, flags=re.MULTILINE)
c = re.sub(r'\b(private|protected)\s+', '', c)
c = re.sub(r'\bfinal\s+', '', c)
c = re.sub(r'\s*throws\s+[\w\s,]+(?=\s*[\{;])', '', c)
c = re.sub(r'\bsynchronized\s+', '', c)
c = re.sub(r'\bnative\s+', '', c)
c = re.sub(r'\btransient\s+', '', c)
c = re.sub(r'\bvolatile\s+', '', c)
c = re.sub(r'\bstrictfp\s+', '', c)
c = re.sub(r'@SuppressWarnings\s*\([^)]*\)\s*\n', '', c)
# assert x [: msg] -> assert:test x [as msg]
c = re.sub(r'assert\s+(.+?)\s*:\s*(.+?);', r'assert:test \1 as \2;', c)
c = re.sub(r'assert\s+(.+?);', r'assert:test \1;', c)

# === XLang type mapping ===
c = re.sub(r'\bnull\b', 'Null', c)
c = re.sub(r'\bboolean\b', 'Boolean', c)
c = re.sub(r'\bint\b', 'Int', c)
c = re.sub(r'\blong\b', 'Int64', c)
c = re.sub(r'\bbyte\b', 'Byte', c)
c = re.sub(r'\bshort\b', 'Short', c)
c = re.sub(r'\bfloat\b', 'Float32', c)
c = re.sub(r'\bdouble\b', 'Float64', c)
c = re.sub(r'\bchar\b', 'Char', c)

# === Pure X patterns ===

# 1. instanceof -> .is() — handles method-call LHS: key.attachment() instanceof T
c = re.sub(r'([\w][\w.()]*)\s+instanceof\s+([\w.<>,\s\[\]]+)', r'\1.is(\2)', c)

# 2. C-cast (Type) expr -> expr.as(Type)
# Pass A: ((Type) expr).method()  -> expr.as(Type).method()
c = re.sub(r'\(\(([A-Z][\w.<>,\s\[\]]+)\)\s*([\w].*?)\)\.', r'\2.as(\1).', c)
# Pass B: standalone cast (Type) expr  where expr is identifier/method-call/field
c = re.sub(r'\(([A-Z][\w.<>,\s\[\]]+)\)\s+([\w]+[\w.()]*(?:\[[^\]]*\])*)', r'\2.as(\1)', c)

# 3. Array init {a, b} -> [a, b]
c = re.sub(r'(=\s*)\{([^}]+)\}', r'\1[\2]', c)
# new Type[] {a, b} -> new Type[] [a, b]
c = re.sub(r'new\s+([\w.\[\]]+)\[\]\s*\{([^}]+)\}', r'[\2]', c)

# 4. Remove generic wildcards — loop for nested cases like <<? extends>>
for _ in range(10):
    nc = re.sub(r'<[^>]*\?[^>]*>', '', c)
    if nc == c: break
    c = nc
# 5. Remove empty diamond <>
c = re.sub(r'<>', '', c)

# 6. Constructor: public Name(params) { -> construct(params) {
# Match: [public] ClassName(params) {  — NOT followed by comma/semicolon (those are enum values)
c = re.sub(r'^\s*(public\s+)?([A-Z]\w*(?:<[^>]+>)?)\s*\(([^)]*)\)\s*\{(\s*)$',
           r'    construct(\3) {\4', c, flags=re.MULTILINE)

# 7. static {} -> static construct() {}
c = re.sub(r'\bstatic\s*\{', 'static construct() {', c)

# 8. Remove super() calls
c = re.sub(r'^\s*super\s*\([^)]*\)\s*;\s*\n', '', c, flags=re.MULTILINE)

# 9. Remove abstract keyword on methods (keep on classes for now)
c = re.sub(r'\babstract\s+(void|Boolean|Int|String|Object|long|int|byte)', r'\1', c)

# === Cleanup ===
c = re.sub(r'  +', ' ', c)
c = re.sub(r'\n\s*\n\s*\n', '\n\n', c)
c = c.rstrip() + '\n'
with open('$xfile', 'w') as f: f.write(c)
"
done

# Write module file
cat > "$OUT_DIR/$MODFILE" << XEOF
module ${MODNAME}.xtclang.org;
XEOF

$VERBOSE && echo "Module: $OUT_DIR/$MODFILE"
$VERBOSE && echo "Sources: $OUT_DIR/$TOP_PKG/ (${#JAVA_FILES[@]} files)"

# Build
XTC="${XTC:-xtc}"
XDK_LIB="/opt/homebrew/Cellar/xdk-latest/0.4.4-SNAPSHOT.20260318082314/libexec/lib"
JT="$XDK_LIB/../javatools"
echo ""
echo "=== xtc build $MODFILE ==="
(cd "$OUT_DIR" && $XTC build "$MODFILE" -L "$XDK_LIB" -L "$JT/javatools_turtle.xtc" -L "$JT/javatools_bridge.xtc" $LIBS 2>&1) && \
    echo "✓ ${MODNAME}.xtclang.org builds clean" || { echo "RLM: fix errors and rebuild"; exit 1; }
