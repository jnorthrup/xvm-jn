@Retention(RetentionPolicy.RUNTIME)
@Target( {FIELD, LOCAL_VARIABLE, TYPE, ANNOTATION_TYPE, CONSTRUCTOR, PACKAGE, PARAMETER})
public @interface DbKeys {
 enum etype {

 opaque, db, docId, rev {
 /**
 * couchdb only returns a quoted etag for entities. this quoted etag breaks in queries sent back to couchdb as rev="breakage"
 * @param data
 * @param <T>
 * @return
 */
 @Override
 public <T> Boolean validate(T... data) {
 String t = data.as(String)[0];
 return t.toString().length() > 0 && !t.startsWith("\"") && !t.endsWith("\"");
 }
 },
 attachname, designDocId, view, validjson, mimetype, mimetypeEnum {
 {
 clazz = MimeType.class;
 }
 },
 blob {
 {
 clazz = ByteBuffer.class;
 }
 },
 type {
 {
 clazz = Type.class;
 }
 },
 keyType {
 {
 clazz = Type.class;
 }
 };

 public <T> Boolean validate(T... data) {
 return true;
 }

 public Class clazz = String.class;
 }

 etype[] value();

 etype[] optional() default {};
}
