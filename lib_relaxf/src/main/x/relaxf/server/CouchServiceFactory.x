public class CouchServiceFactory {
static Object get(Class clazz, String[] ns) {
InvocationHandler handler = new CouchServiceHandler(clazz, ns);
Class[] interfaces = [clazz];
return Proxy.newProxyInstance(clazz.getClassLoader(), interfaces, handler);
}

static class CouchServiceHandler<E> implements InvocationHandler, CouchNamespace {
static ExecutorService work = Executors.newFixedThreadPool(1);
Class entityType;
Map<String, String> viewMethods = Null;
Future<Void> init;
String entityName;

String orgname;

String pathPrefix;
construct (Class serviceInterface, String[] ns) {
    Type[] genericInterfaces = serviceInterface.getGenericInterfaces();

    ParameterizedType genericInterface =  genericInterfaces[0];
    assert CouchService.class.isAssignableFrom(genericInterface.getRawType()) : genericInterface;
    entityType = genericInterface.getActualTypeArguments()[0];
    init(serviceInterface, ns);
}
void init(Class serviceInterface, String[] initNs) {
init = work.submit(new Callable<Void>() {
Void call() {

ensureDbExists(getPathPrefix());

CouchDesignDoc design = new CouchDesignDoc();
String designId = "_design/" + serviceInterface.getName();
design.id = designId;
CouchDesignDoc existingDesignDoc = Null;
String pathPrefix1 = getPathPrefix();
design.version = RevisionFetch.$().db(pathPrefix1).docId(designId).to().fire().json();
Map<String, Type> returnTypes = new TreeMap<String, Type>();
viewMethods = new TreeMap<String, String>();
for (Method m : serviceInterface.getMethods()) {
String methodName = m.getName();
returnTypes.put(methodName, m.getReturnType());
View viewAnnotation = m.getAnnotation(View.class);
if (Null != viewAnnotation) {
CouchView view = new CouchView();
view.map = viewAnnotation.map();
view.reduce = viewAnnotation.reduce();
design.views.put(methodName, view);
StringBuilder queryBuilder =
new StringBuilder(designId).append("/_view/").append(methodName).append("?");

Annotation[][] paramAnnotations = m.getParameterAnnotations();
if (paramAnnotations.size == 1 && paramAnnotations[0].size == 0) {

queryBuilder.append("key=%1$s");
} else {

Map<String, String> queryParams = new TreeMap<String, String>();
for (Int i = 0; i < paramAnnotations.size; i++) {

Annotation[] param = paramAnnotations[i];
for (Int j = 0; j < param.size; j++) {
CouchRequestParam paramData =
param[j].annotationType().getAnnotation(CouchRequestParam.class);
if (paramData != Null) {
queryParams.put(paramData.value(), "%" + (i + 1) + "$s");
break;
}
}
}

Annotation[] methodAnnotations = m.getAnnotations();
for (Annotation a : methodAnnotations) {
CouchRequestParam paramData =
a.annotationType().getAnnotation(CouchRequestParam.class);
if (paramData != Null) {
Object obj = a.annotationType().getMethod("value").invoke(a);
String val =
paramData.isJson() ? CouchMetaDriver.gson().toJson(obj) : obj + "";
queryParams.put(paramData.value(), URLEncoder.encode(val, "UTF-8"));
}
}
for (Map.Entry<String, String> param : queryParams.entrySet()) {

queryBuilder.append(URLEncoder.encode(param.getKey(), "UTF-8")).append("=")
.append(param.getValue()).append("&");
}
}
viewMethods.put(methodName, queryBuilder.toString());
}
}
viewMethods = Collections.unmodifiableMap(viewMethods);

if (!viewMethods.empty
&& (Null == design.version || !design.equals(existingDesignDoc =
CouchMetaDriver.gson().fromJson(
DocFetch.$().db(pathPrefix1).docId(designId).to().fire().json(),
CouchDesignDoc.class)))) {
System.err.println("Existing design doc out of date, updating...");
}
String stringParam = CouchMetaDriver.gson().toJson(design);
JsonSendTerminalBuilder fire = JsonSend.$().opaque(getPathPrefix())
.validjson(stringParam).to().fire();
if (BlobAntiPatternObject.DEBUG_SENDJSON) {
CouchTx tx = fire.tx();
assert tx.ok() : tx.error();
System.err.println(deepToString(tx));
} else {
fire.future().get();
}
return Null;
}
});
}
Boolean ensureDbExists(String dbName) {
String json = DocFetch.$().db("").docId(dbName).to().fire().json();
if (json == Null) {

CouchTx tx = DbCreate.$().db(getPathPrefix()).to().fire().tx();
assert tx.ok() : tx.error();
System.err.println("had to create " + dbName);
return False;
}
return True;
}

Object invoke(Object proxy, Method method, Object[] args){
init.get();
if (viewMethods.containsKey(method.getName())) {

String name = method.getName();
String[] jsonArgs = Null;
if (args != Null) {
jsonArgs = new String[args.size];
for (Int i = 0; i < args.size; i++) {
jsonArgs[i] = URLEncoder.encode(CouchMetaDriver.gson().toJson(args[i]), "UTF-8");
}
}
Type keyType = Object;
Type valueType;
if (method.getGenericReturnType().is(Class)) {

if (method.getReturnType().isPrimitive()) {
valueType = Primitives.wrap(method.getReturnType());
} else {
valueType = method.getReturnType();
}

ParameterizedType returnType =  method.getGenericReturnType();
if (returnType.getRawType() == Map.class) {
Map map = new HashMap();

keyType = returnType.getActualTypeArguments()[0];
valueType = returnType.getActualTypeArguments()[1];
} else if (returnType.getRawType() == List.class) {
valueType = returnType.getActualTypeArguments()[0];
} else {

valueType = entityType;
}
}
/* dont forget to uncomment this after new CouchResult gen*/
Map<String, String> stringStringMap = viewMethods;

String format = String.format(stringStringMap.get(name), jsonArgs);
ViewFetchTerminalBuilder fire =
ViewFetch.$().db(getPathPrefix()).type(valueType).keyType(keyType).view(format).to()
.fire();
        CouchResultSet rows = fire.rows();
if (rows == Null || rows.rows == Null) {
return Null;
}
if (method.getGenericReturnType().is(Class)) {

if (rows.rows.empty) {
return Defaults.defaultValue((Class<Object>) method.getReturnType());
}
}
return rows.rows.get(0).value;
} else {

ParameterizedType returnType =  method.getGenericReturnType();
if (returnType.getRawType() == Map.class) {
Map map = new HashMap();

if (Null != rows && Null != rows.rows) {
for (tuple<?, ?> row : rows.rows) {
map.put(row.key, (E) row.value);
}
}

return map;
} else if (returnType.getRawType() == List.class) {
List list = new ArrayList();

if (Null != rows && Null != rows.rows) {
List<E> ar = new ArrayList<E>();
for (tuple<?, ?> row : rows.rows) {
ar.add((E) row.value);
}
return ar;
}
}
}
return Null;
} else {

if ("persist".equals(method.getName())) {

String stringParam = CouchMetaDriver.gson().toJson(args[0]);
DocPersistActionBuilder to =
DocPersist.$().db(getPathPrefix()).validjson(stringParam).to();
DocPersistTerminalBuilder fire = to.fire();
CouchTx tx = fire.tx();
return tx;
} else if ("attachments".equals(method.getName())) {
try {
return new AttachmentsImpl(getPathPrefix(), (E) args[0]);
} catch (NoSuchFieldException e) {
e.printStackTrace();
} catch (IllegalAccessException e) {
e.printStackTrace();
}
return Null;
} else {
assert "find".equals(method.getName());
String doc = DocFetch.$().db(getPathPrefix()).docId( args[0]).to().fire().json();
return (E) CouchMetaDriver.gson().fromJson(doc, entityType);
}
}
}
String getEntityName() {
return Null == entityName ? entityName = getDefaultEntityName() : entityName;
}
void setEntityName(String entityName) {
this.entityName = entityName;
}
String getDefaultEntityName() {
return entityType.getSimpleName().toLowerCase();
}
String getOrgName() {
return Null == orgname ? orgname = getDefaultOrgName() : orgname;
}
void setOrgname(String orgname) {
this.orgname = orgname;
}
String getPathPrefix() {
return Null == pathPrefix ? pathPrefix = getOrgName() + getEntityName() : pathPrefix;
}
void setPathPrefix(String pathPrefix) {
this.pathPrefix = pathPrefix;
}
static class CouchView {
String map;
String reduce;

Boolean equals(Object obj) {
if (!(obj.is(CouchView))) {
return False;
}
CouchView other = (CouchView) obj;
return ((map == Null && other.map == Null) || map.equals(other.map))
&& ((reduce == Null && other.reduce == Null || reduce.equals(other.reduce)));
}
}
static class CouchDesignDoc {
@SerializedName("_id")
String id;
@SerializedName("_rev")
String version;
String language = "javascript";
Map<String, CouchView> views = new TreeMap<String, CouchView>();

Boolean equals(Object obj) {
if (!(obj.is(CouchDesignDoc))) {
return False;
}
CouchDesignDoc other = (CouchDesignDoc) obj;
return id.equals(other.id) && views.equals(other.views);
}
}
}
}