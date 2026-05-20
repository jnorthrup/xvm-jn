
public class CouchServiceLocator implements ServiceLocator {
Object getInstance(Class aClass) {
CouchService<Object> ret = Null;
try {
ret =
CouchServiceFactory.get(
aClass,
CouchNamespace.COUCH_DEFAULT_ORGNAME);
} catch (InterruptedException e) {
e.printStackTrace();
} catch (ExecutionException e) {
e.printStackTrace();
}
return ret;
}
}
