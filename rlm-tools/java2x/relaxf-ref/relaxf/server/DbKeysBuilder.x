/**
 * User: jim
 * Date: 5/29/12
 * Time: 1:58 PM
 */
public abstract class DbKeysBuilder {
 static ThreadLocal<DbKeysBuilder> currentKeys =
 new InheritableThreadLocal<DbKeysBuilder>();
 java.util.EnumMap<DbKeys.etype, Object> parms =
 new java.util.EnumMap<DbKeys.etype, Object>(DbKeys.etype.class);

 Throwable trace;

 abstract ActionBuilder to();
 construct() {
 currentKeys.set(this);
 if (BlobAntiPatternObject.DEBUG_SENDJSON) {
 debug();
 }

 }

 public Boolean validate() {
 for (etype etype : parms.keySet()) {
 Object o = get(etype);
 if (!etype.validate(o)) {
 throw new ValidationException("!!! " + etype + " fails with value: " + o);
 }
 }
 return true;
 }

 public static DbKeysBuilder get() {
 return currentKeys.get();
 }

 public <T> T get(etype key) {
 return (T) parms.get(key);
 }

 public <T> T put(etype k, T v) {
 return (T) parms.put(k, v);
 }

 public <T> T remove(etype designDocId) {
 return (T) parms.remove(designDocId);
 }

 /**
 * creates a trace object here and now.
 *
 * @return
 */
 public DbKeysBuilder debug() {
 trace = new Throwable().fillInStackTrace();
 return this;
 }

 public Throwable trace() {
 return trace;
 }
}
