#!/usr/bin/env bash
# rlm_loop.sh — automatic RLM loop: convert Java → XTC, build, fix, repeat
#
# Usage:
#   rlm_loop.sh <src-dir> <out-dir> --module <name> [--max <N>] [--lib <path>]
#
# Each iteration:
#   1. nuke out-dir
#   2. run java2x.py on every .java (javap skeleton as comments)
#   3. write module file
#   4. xtc build
#   5. if errors → hermes "fix java2x.py to eliminate: <errors>" → go to 1
#   6. if clean → done
#
# The loop edits java2x.py (the script), not the .x files.
# hermes is the AI harness that patches java2x.py each iteration.

set -euo pipefail
ME=$(basename "$0")
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JAVA2X_PY="$SCRIPT_DIR/java2x.py"

usage() {
    echo "Usage: $ME <src-dir> <out-dir> --module <name> [--max <N>] [--lib <path>] [--skip-javap]"
    exit 1
}

SRC_DIR=""; OUT_DIR=""; MODNAME=""; MAX=20; LIBS=""; SKIP_JAVAP=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --module)    MODNAME="$2"; shift 2 ;;
        --max)       MAX="$2";    shift 2 ;;
        --lib)       LIBS="$LIBS $2"; shift 2 ;;
        --skip-javap) SKIP_JAVAP="--skip-javap"; shift ;;
        -h|--help)   usage ;;
        *)
            if   [[ -z "$SRC_DIR" ]]; then SRC_DIR="$1"
            elif [[ -z "$OUT_DIR"  ]]; then OUT_DIR="$1"
            else usage
            fi
            shift ;;
    esac
done

[[ -n "$SRC_DIR" && -n "$OUT_DIR" && -n "$MODNAME" ]] || usage
[[ -d "$SRC_DIR" ]] || { echo "Error: $SRC_DIR not a directory"; exit 1; }

MODNAME=$(echo "$MODNAME" | sed 's/[^a-zA-Z0-9]/_/g;s/-/_/g' | tr '[:upper:]' '[:lower:]')
MODFILE="x_${MODNAME}.x"

XDK_LIB="/opt/homebrew/Cellar/xdk-latest/0.4.4-SNAPSHOT.20260318082314/libexec/lib"
JT="$XDK_LIB/../javatools"
XTC="${XTC:-xtc}"

# Collect java sources
JAVA_FILES=()
while IFS= read -r f; do JAVA_FILES+=("$f"); done \
    < <(find "$SRC_DIR" -name '*.java' -not -path '*/test/*' -not -path '*/build/*' | sort)
[[ ${#JAVA_FILES[@]} -gt 0 ]] || { echo "Error: no .java files in $SRC_DIR"; exit 1; }
echo "[$ME] ${#JAVA_FILES[@]} Java files, max $MAX iterations"

# ── helper: map java package path → x subdir ────────────────────────────────
map_pkg_dir() {
    local rel="$1" base="$OUT_DIR/$MODNAME"
    case "$rel" in
        */server*) echo "$base/server" ;;
        */rsync*)  echo "$base/rsync"  ;;
        */couch*)  echo "$base/couch"  ;;
        *)         echo "$base/server" ;;
    esac
}

# ── main RLM loop ────────────────────────────────────────────────────────────
for ((iter=1; iter<=MAX; iter++)); do
    echo ""
    echo "════════════════════════════════════════"
    echo "  RLM iteration $iter / $MAX"
    echo "════════════════════════════════════════"

    # 1. nuke output
    rm -rf "$OUT_DIR"
    mkdir -p "$OUT_DIR/$MODNAME/server" "$OUT_DIR/$MODNAME/rsync" "$OUT_DIR/$MODNAME/couch"

    # 2. convert each .java → .x via java2x.py
    CONVERT_ERRORS=""
    for java in "${JAVA_FILES[@]}"; do
        rel="${java#$SRC_DIR/}"
        base=$(basename "$java" .java)
        xdir=$(map_pkg_dir "$rel")
        mkdir -p "$xdir"
        xfile="$xdir/${base}.x"
        set +e
        py_out=$(python3 "$JAVA2X_PY" "$java" "$xfile" \
            --adapters-dir "$xdir" $SKIP_JAVAP 2>&1)
        py_rc=$?
        set -e
        echo "  $rel → ${xfile#$OUT_DIR/}  $py_out"
        if [[ $py_rc -ne 0 ]]; then
            CONVERT_ERRORS="$CONVERT_ERRORS\npython error on $java:\n$py_out"
        fi
    done

    # 3. write module file
    echo "module ${MODNAME}.xtclang.org;" > "$OUT_DIR/$MODFILE"

    # 4. if python itself broke, ask hermes to fix java2x.py then retry
    if [[ -n "$CONVERT_ERRORS" ]]; then
        echo ""
        echo "[RLM] java2x.py raised errors — asking hermes to fix"
        hermes -p "You are fixing a Java→XTC transform script. The script is $JAVA2X_PY.
These Python errors occurred during conversion:
$CONVERT_ERRORS

Read the script, fix only the Python errors (do not change the transform logic unless the error is in it), then save the fixed version back to $JAVA2X_PY.
Do not explain. Just fix and save." 2>&1
        continue
    fi

    # 5. xtc build
    echo ""
    echo "  [xtc build]"
    set +e
    BUILD_OUT=$( (cd "$OUT_DIR" && $XTC build "$MODFILE" \
        -L "$XDK_LIB" \
        -L "$JT/javatools_turtle.xtc" \
        -L "$JT/javatools_bridge.xtc" \
        $LIBS 2>&1) )
    BUILD_RC=$?
    set -e
    echo "$BUILD_OUT"

    if [[ $BUILD_RC -eq 0 ]]; then
        echo ""
        echo "✓ $MODNAME builds clean after $iter iteration(s)"
        exit 0
    fi

    # 6. errors → hermes patches java2x.py
    # Extract only xtc error lines to keep context small
    XTC_ERRORS=$(echo "$BUILD_OUT" | grep -E '(error|PARSER|COMPILER|warning)' | head -40 || true)
    echo ""
    echo "[RLM] xtc errors — asking hermes to evolve java2x.py"
    echo "$XTC_ERRORS"

    hermes -p "You are evolving a Java→XTC transform script to eliminate compiler errors.
Script: $JAVA2X_PY
XTC compiler errors from latest run:
$XTC_ERRORS

Rules:
- Edit ONLY $JAVA2X_PY (the transform script). Never edit .x output files.
- Produce pure XTC output — do NOT rely on xtc's Java backward-compat mode.
- Pure X means: .is() not instanceof, .as() not (Type)cast, construct() not ClassName(),
  Boolean/Int/Int64/Null not boolean/int/long/null, [a,b] not {a,b}.
- Each fix should eliminate the pattern causing the first error.
- Do not explain. Just fix and save." 2>&1

done

echo ""
echo "✗ RLM: did not converge in $MAX iterations"
exit 1
