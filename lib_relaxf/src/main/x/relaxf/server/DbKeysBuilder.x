
public class DbKeysBuilder {
static ThreadLocal<DbKeysBuilder> currentKeys =
new InheritableThreadLocal<DbKeysBuilder>();
java.util.EnumMap<Object, Object> parms =
new java.util.EnumMap<Object, Object>(typeof(DbKeys.etype));
Throwable trace;
ActionBuilder to();
construct() {
currentKeys.set(this);
if (BlobAntiPatternObject.DEBUG_SENDJSON) {
debug();
}
Boolean validate() {
for (etype etype : parms.keySet()) {
Object o = get(etype);
if (!etype.validate(o)) {
throw new ValidationException("!!! " + etype + " fails with value: " + o);
}
}
return True;
}
}
static DbKeysBuilder get() {
return currentKeys.get();
}
<T> T get(etype key) {
return parms.get(key);
}
<T> T put(etype k, T v) {
return parms.put(k, v);
}
<T> T remove(etype designDocId) {
return parms.remove(designDocId);
}

DbKeysBuilder debug() {
trace = new Throwable().fillInStackTrace();
return this;
}
Throwable trace() {
return trace;
}
}
