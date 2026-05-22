/**
 * this class holds a protocol namespace to dispatch requests
 * <p/>
 * {@link rxf.server.CouchNamespace#NAMESPACE } is a map of http methods each containing an ordered map of regexes tested in order of
 * map insertion.
 * <p/>
 * User: jim
 * Date: 4/18/12
 * Time: 12:37 PM
 */
public class ProtocolMethodDispatch extends Impl {

 public static ByteBuffer NONCE = ByteBuffer.allocateDirect(0);

 /**
 * the PUT protocol handlers, only static for the sake of javadocs
 */
 public static Map> POSTmap =
 new LinkedHashMap();

 /**
 * the GET protocol handlers, only static for the sake of javadocs
 */
 public static Map> GETmap =
 new LinkedHashMap();

 static construct() {
 NAMESPACE.put(POST, POSTmap);
 NAMESPACE.put(GET, GETmap);

 /**
 * for gwt requestfactory done via POST.
 *
 * TODO: rf GET from query parameters
 */
 POSTmap.put(Pattern.compile("^/gwtRequest"), GwtRequestFactoryVisitor.class);

 /**
 * any url begining with /i is a proxied $req to couchdb but only permits image/* and text/*
 */

 Pattern passthroughExpr = Pattern.compile("^/i(/.*)$");
 GETmap.put(passthroughExpr, HttpProxyImpl.class/*(passthroughExpr)*/);

 /**
 * general purpose httpd static content server that recognizes .gz and other compression suffixes when convenient
 *
 * any random config mechanism with a default will suffice here to define the content root.
 *
 * widest regex last intentionally
 * system proprty: {value #RXF_SERVER_CONTENT_ROOT}
 */
 GETmap.put(ContentRootCacheImpl.CACHE_PATTERN, ContentRootCacheImpl.class);
 GETmap.put(ContentRootNoCacheImpl.NOCACHE_PATTERN, ContentRootNoCacheImpl.class);
 GETmap.put(Pattern.compile(".*"), ContentRootImpl.class );
 }

 public void onAccept(SelectionKey key){
 ServerSocketChannel channel = key.channel().as(ServerSocketChannel);
 SocketChannel accept = channel.accept();
 accept.configureBlocking(false);
 HttpMethod.enqueue(accept, OP_READ, this);

 }

 public void onRead(SelectionKey key){
 SocketChannel channel = key.channel().as(SocketChannel);

 ByteBuffer cursor = ByteBuffer.allocateDirect(BlobAntiPatternObject.getReceiveBufferSize());
 Int read = channel.read(cursor);
 if (-1 == read) {
 key.channel().as(SocketChannel).socket().close();//cancel();
 return;
 }

 HttpMethod method = Null;
 HttpRequest httpRequest = Null;
 try {
 //find the method to dispatch
 Rfc822HeaderState state = new Rfc822HeaderState().apply(cursor.flip().as(ByteBuffer));
 httpRequest = state.$req();
 if (BlobAntiPatternObject.DEBUG_SENDJSON) {
 System.err.println(BlobAntiPatternObject.deepToString(UTF8.decode(httpRequest.as(ByteBuffer)
 .headerBuf().duplicate().rewind())));
 }
 String method1 = httpRequest.method();
 method = HttpMethod.valueOf(method1);

 } catch (Exception e) {
 }

 if (Null == method) {
 key.channel().as(SocketChannel).socket().close();//cancel();

 return;
 }

 Set>> entries = NAMESPACE.get(method).entrySet();
 String path = httpRequest.path();
 for (Entry> visitorEntry : entries) {
 Matcher matcher = visitorEntry.getKey().matcher(path);
 if (matcher.find()) {
 if (BlobAntiPatternObject.DEBUG_SENDJSON) {
 System.err.println("+?+?+? using " + matcher.toString());
 }
 Class value = visitorEntry.getValue();
 Impl impl;

 impl = value.newInstance();
 Object a[] = [impl, httpRequest, cursor];
 key.attach(a);
 if (PreRead.class.isAssignableFrom(value)) impl.onRead(key);
 key.selector().wakeup();
 return;
 }

 }
 System.err.println(BlobAntiPatternObject.deepToString("!!!1!1!!", "404", path, "using",
 NAMESPACE));
 }

}
