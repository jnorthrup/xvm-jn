#!/usr/bin/env python3
"""
java2x.py — Java → pure XTC transform pipeline
Usage: java2x.py <input.java> <output.x> [--javap-jar <jar>]

Transforms Java source to pure XTC (no Java compatibility mode).
javap skeleton is emitted as comments at the top of each output file.
"""
import re, sys, os, subprocess, argparse

def javap_skeleton(java_file: str, classpath=None) -> str:
    """Run javac+javap on the .java file and return skeleton as comment block."""
    import tempfile, shutil
    tmpdir = tempfile.mkdtemp()
    try:
        cp = classpath or "."
        r = subprocess.run(
            ["javac", "-cp", cp, "-d", tmpdir, java_file],
            capture_output=True, text=True
        )
        if r.returncode != 0:
            return f"// javap: javac failed\n// {r.stderr.strip()}\n"
        # find the .class
        classes = []
        for root, _, files in os.walk(tmpdir):
            for f in files:
                if f.endswith(".class") and "$" not in f:
                    classes.append(os.path.join(root, f))
        if not classes:
            return "// javap: no class output\n"
        lines = ["// === javap skeleton (parity guide) ==="]
        for cls in sorted(classes):
            r2 = subprocess.run(
                ["javap", "-p", cls], capture_output=True, text=True
            )
            for line in r2.stdout.splitlines():
                lines.append("// " + line)
        lines.append("// === end javap skeleton ===")
        return "\n".join(lines) + "\n\n"
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


# ── non-portable Java patterns that need X context adapters ──────────────────
ADAPTER_PATTERNS = [
    ("com.google.gson",   "GsonAdapter"),
    ("java.sql.",         "JdbcAdapter"),
    ("java.net.http.",    "HttpClientAdapter"),
    ("javax.servlet.",    "ServletAdapter"),
]

def detect_adapters(imports: list[str]) -> list[str]:
    needed = set()
    for imp in imports:
        for pkg, name in ADAPTER_PATTERNS:
            if pkg in imp:
                needed.add(name)
    return sorted(needed)


def adapter_body(name: str) -> str:
    bodies = {
        "GsonAdapter": """\
service GsonAdapter {
    // Auto-generated X context adapter — wraps com.google.gson via javatools bridge
    // Thunking overhead acknowledged: each call crosses the X/Java boundary
    static String toJson(Object obj) {
        @Inject com.google.gson.Gson gson;
        return gson.toJson(obj);
    }
    static <T> T fromJson(String json, Class<T> cls) {
        @Inject com.google.gson.Gson gson;
        return gson.fromJson(json, cls);
    }
}
""",
        "JdbcAdapter": """\
service JdbcAdapter {
    // Auto-generated X context adapter — wraps java.sql via javatools bridge
    // Thunking overhead acknowledged: each call crosses the X/Java boundary
    static java.sql.Connection connect(String url) {
        return java.sql.DriverManager.getConnection(url);
    }
    static java.sql.Connection connect(String url, String user, String pass) {
        return java.sql.DriverManager.getConnection(url, user, pass);
    }
}
""",
        "HttpClientAdapter": """\
service HttpClientAdapter {
    // Auto-generated X context adapter — wraps java.net.http via javatools bridge
    static String get(String url) {
        var client = java.net.http.HttpClient.newHttpClient();
        var req = java.net.http.HttpRequest.newBuilder(java.net.URI.create(url)).build();
        return client.send(req, java.net.http.HttpResponse.BodyHandlers.ofString()).body();
    }
}
""",
    }
    return bodies.get(name, f"service {name} {{\n    // TODO: implement\n}}\n")


def transform(src: str) -> tuple[str, list[str]]:
    """
    Apply all transforms to Java source.
    Returns (transformed_source, list_of_needed_adapter_names).
    """
    c = src

    # ── 0. Capture imports BEFORE stripping (needed for adapter detection) ───
    raw_imports = re.findall(r'^import\s+(?:static\s+)?[\w.*]+\s*;', c, flags=re.MULTILINE)

    # ── 1. Strip Java boilerplate ────────────────────────────────────────────
    c = re.sub(r'^package\s+[\w.]+\s*;\s*\n', '', c, flags=re.MULTILINE)
    c = re.sub(r'^import\s+(?:static\s+)?[\w.*]+\s*;\s*\n', '', c, flags=re.MULTILINE)
    c = re.sub(r'\b(private|protected)\s+', '', c)
    c = re.sub(r'\bfinal\s+', '', c)
    c = re.sub(r'\s*throws\s+[\w\s,]+(?=\s*[{;])', '', c)
    c = re.sub(r'\bsynchronized\s+', '', c)
    c = re.sub(r'\bnative\s+', '', c)
    c = re.sub(r'\btransient\s+', '', c)
    c = re.sub(r'\bvolatile\s+', '', c)
    c = re.sub(r'\bstrictfp\s+', '', c)
    c = re.sub(r'@SuppressWarnings\s*\([^)]*\)\s*\n', '', c)

    # ── 2. assert ────────────────────────────────────────────────────────────
    c = re.sub(r'assert\s+(.+?)\s*:\s*(.+?);', r'assert:test \1 as \2;', c)
    c = re.sub(r'assert\s+(.+?);', r'assert:test \1;', c)

    # ── 3. XLang primitive type mapping ──────────────────────────────────────
    c = re.sub(r'\bnull\b', 'Null', c)
    c = re.sub(r'\bboolean\b', 'Boolean', c)
    c = re.sub(r'\bint\b', 'Int', c)
    c = re.sub(r'\blong\b', 'Int64', c)
    c = re.sub(r'\bbyte\b', 'Byte', c)
    c = re.sub(r'\bshort\b', 'Short', c)
    c = re.sub(r'\bfloat\b', 'Float32', c)
    c = re.sub(r'\bdouble\b', 'Float64', c)
    c = re.sub(r'\bchar\b', 'Char', c)

    # ── 4. instanceof → .is() ────────────────────────────────────────────────
    c = re.sub(r'([\w][\w.()*]*)\s+instanceof\s+([\w.<>,\s\[\]]+)', r'\1.is(\2)', c)

    # ── 5. C-casts → .as() ───────────────────────────────────────────────────
    # Pass A: double-parens ((Type) expr).method()
    c = re.sub(r'\(\(([A-Z][\w.<>,\s\[\]]+)\)\s*([\w].*?)\)\.', r'\2.as(\1).', c)
    # Pass B: standalone (Type) expr
    c = re.sub(r'\(([A-Z][\w.<>,\s\[\]]+)\)\s+([\w]+[\w.()]*(?:\[[^\]]*\])*)', r'\2.as(\1)', c)

    # ── 6. Array init {a,b} → [a,b] ──────────────────────────────────────────
    c = re.sub(r'(=\s*)\{([^}]+)\}', r'\1[\2]', c)
    c = re.sub(r'new\s+[\w.\[\]]+\[\]\s*\{([^}]+)\}', r'[\1]', c)

    # ── 7. Remove generic wildcards / empty diamonds ──────────────────────────
    for _ in range(10):
        nc = re.sub(r'<[^>]*\?[^>]*>', '', c)
        if nc == c: break
        c = nc
    c = re.sub(r'<>', '', c)

    # ── 8. Constructor: ClassName(params) { → construct(params) { ────────────
    c = re.sub(
        r'^\s*(?:public\s+)?([A-Z]\w*(?:<[^>]+>)?)\s*\(([^)]*)\)\s*\{(\s*)$',
        r'    construct(\2) {\3', c, flags=re.MULTILINE
    )

    # ── 9. static {} → static construct() {} ─────────────────────────────────
    c = re.sub(r'\bstatic\s*\{', 'static construct() {', c)

    # ── 10. Remove super() calls ──────────────────────────────────────────────
    c = re.sub(r'^\s*super\s*\([^)]*\)\s*;\s*\n', '', c, flags=re.MULTILINE)

    # ── 11. abstract keyword on methods (not classes) ─────────────────────────
    c = re.sub(r'\babstract\s+(void|Boolean|Int|String|Object|Int64|Byte|Float)', r'\1', c)

    # ── Cleanup ───────────────────────────────────────────────────────────────
    c = re.sub(r'  +', ' ', c)
    c = re.sub(r'\n\s*\n\s*\n', '\n\n', c)
    c = c.rstrip() + '\n'

    adapters = detect_adapters(raw_imports)
    return c, adapters


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input")
    ap.add_argument("output")
    ap.add_argument("--javap-jar", default=None, help="extra classpath for javap compilation")
    ap.add_argument("--adapters-dir", default=None, help="directory to write adapter .x files")
    ap.add_argument("--skip-javap", action="store_true")
    args = ap.parse_args()

    with open(args.input) as f:
        src = f.read()

    skeleton = "" if args.skip_javap else javap_skeleton(args.input, args.javap_jar)
    body, adapters = transform(src)

    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    with open(args.output, "w") as f:
        f.write(skeleton)
        f.write(body)

    # write adapters
    adir = args.adapters_dir or os.path.dirname(os.path.abspath(args.output))
    for name in adapters:
        apath = os.path.join(adir, f"{name}.x")
        if not os.path.exists(apath):          # never clobber a hand-edited adapter
            with open(apath, "w") as f:
                f.write(adapter_body(name))
            print(f"  [adapter] {apath}", file=sys.stderr)

    if adapters:
        print(f"  [needs adapters] {' '.join(adapters)}", file=sys.stderr)


if __name__ == "__main__":
    main()
