# Pijul Delta Parameterization

The 2.2MB of CRDT patches are bound to RelaxFactory-specific content offsets.
The java2x.sh converter is the **parameterized form**:

## Delta 1 → package map (6 rules)
```python
# Per-project: change this mapping
map_pkg_dir = {
    "one/xio":       relaxf/,       # reactor core
    "rxf/server*":   relaxf/server/ # main server
    "rxf/rsync*":    relaxf/rsync/  # file watcher
    "rxf/couch*":    relaxf/couch/  # couchdb driver
}
```

## Delta 2 → regex pipeline (12 rules)
```python
# Project-agnostic: apply to any Java source
# Strip: package, import, private, protected, final, throws
# Types: boolean→Boolean, int→Int, null→Null, etc.
# Patterns: instanceof→.is, (T)x→x.as(T), {a,b}→[a,b]
# Constructors: Name(params)→construct(params)
# Blocks: static{}→static construct(){}
```

To reparameterize for a new project:
1. Copy `scripts/java2x.sh` → `myport.sh`
2. Edit `map_pkg_dir()` for your package structure
3. Run: `bash myport.sh --module myproject <java-src> <out-dir>`
4. RLMs: fix regex damage in the output, rebuild
