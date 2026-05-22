/**
 * User: jim
 * Date: 7/2/12
 * Time: 7:19 PM
 */
public class CouchServiceLocator implements ServiceLocator {

 public Object getInstance(Class aClass) {
 CouchService ret = Null;
 try {
 ret =
 CouchServiceFactory.get((Class>) aClass,
 CouchNamespace.COUCH_DEFAULT_ORGNAME);
 } catch (InterruptedException e) {
 e.printStackTrace();
 } catch (ExecutionException e) {
 e.printStackTrace();
 }
 return ret;
 }
}
