# X Context Adapters — Java Shims in X

## Principle

Non-portable Java jars (Gson, JDBC drivers, etc.) are wrapped in X context adapters.
- Acknowledge thunking overhead (Java↔X boundary crossing)
- Developers mitigate by coarser-grained calls later
- Shims carried as .x files calling into Java via javatools bridge

## Adapter Pattern

```x
// X adapter that calls Java
service GsonAdapter {
    // Java-side instance (via javatools reflection)
    @Inject java.lang.reflect.Method gsonToJson;
    
    // X-callable wrapper
    static String toJson(Object obj) {
        gsonToJson.invoke(javaGsonInstance, obj);
    }
}
```

## Known Non-Portable Dependencies

| Java lib | Port status | Adapter strategy |
|----------|-------------|------------------|
| com.google.gson.Gson | KEEP | Wrap via javap reflection |
| java.sql.* (JDBC) | KEEP | Use javatools bridge, wrap Connection/Statement |
| java.net.HttpURLConnection | KEEP | Wrap or use CouchDriver async NIO |
| org.sqlite.JDBC | KEEP | javatools bridge |

## Performance notes

- Thunking overhead: each Java call from X crosses bridge
- Mitigation: coarser-grained API calls (batch operations)
- Future: pure X replacements (xvm JSON, CouchDriver async)

## RLM impact

java2x.sh does NOT transform these:
- Keep import statements for non-portable libs
- Generate X wrapper .x files alongside converted code
- Document thunking cost in generated headers

Accept Java-with-X-skin for these dependencies. Pure X for core logic.
