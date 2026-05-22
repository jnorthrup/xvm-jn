/**
 * <ul>
 * <li> Accepts external socket connections on behalf of Couchdb or other REST server
 * <p/>
 * </ul>
 *
 * User: jnorthrup
 * Date: 10/1/13
 * Time: 7:26 PM
 */
public class ProxyDaemon extends AsioVisitor.Impl {
 /**
 * until proven otherwise, all http requests must conform to crlf line-endings, and it is the primary termination token we are seeking in bytebuffer operations.
 */
 public static Byte[] TERMINATOR = new Byte[] {'\r', '\n', '\r', '\n'};
 /**
 * a shortcut to locating the Host header uses this length
 */
 public static Int HOSTPREFIXLEN = "Host: ".length();

 public static Int PROXY_PORT = Integer.parseInt(getVar("PROXY_PORT", "0"));
 public static String PROXY_HOST = getVar("PROXY_HOST", "127.0.0.1");
 static Boolean RPS_SHOW = "true".equals(getVar("RPS_SHOW", "true"));
 static Boolean PROXY_DEBUG = "true".equals(getVar("PROXY_DEBUG", "false"));
 /**
 * master counter for stats on inbound requests
 */
 public static Int counter = 0;
 public FileChannel hdrStream;
 /**
 * request lead-in data is placed in this buffer.
 */
 ByteBuffer cursor;

 ProxyTask proxyTask;

 InetSocketAddress preallocAddr;
 construct(ProxyTask... proxyTask) {
 this.proxyTask = proxyTask.length > 0 ? proxyTask[0] : new ProxyTask();

 if (PROXY_PORT != 0)
 try {
 preallocAddr = new InetSocketAddress(InetAddress.getByName(PROXY_HOST), PROXY_PORT);
 } catch (UnknownHostException e) {
 e.printStackTrace();
 }
 }

 /**
 * creates a http-specific socket proxy to move bytes between innerKey and outerKey in the async framework.
 *
 * @param outerKey connection to the f5
 * @param innerKey connection to the Distributor
 * @param b the DMA ByteBuffers where applicable
 */
 public static void pipe(SelectionKey innerKey, SelectionKey outerKey, ByteBuffer... b) {
 String s = "pipe-" + counter;
 ByteBuffer ob = b.length > 1 ? b[1] : ByteBuffer.allocate(4 << 10);
 HttpPipeVisitor ib = new HttpPipeVisitor(s + "-in", innerKey, b[0], ob);
 outerKey.interestOps(OP_READ | OP_WRITE).attach(ib);
 innerKey.interestOps(OP_WRITE);
 innerKey.attach(new HttpPipeVisitor(s + "-out", outerKey, ob, b[0]) {
 public Boolean fail;

 @Override
 public void onRead(SelectionKey key){
 if (!ib.isLimit() || fail) {
 SocketChannel channel = key.channel().as(SocketChannel);
 Int read = channel.read(getInBuffer());
 switch (read) {
 case -1:
 channel.close();
 case 0:
 return;
 default:
 Rfc822HeaderState.HttpResponse httpResponse =
 new Rfc822HeaderState().headerInterest(HttpHeaders.Content$2dLength).apply(
 getInBuffer().duplicate().flip().as(ByteBuffer)).$res();
 // if (BlobAntiPatternObject.suffixMatchChunks(TERMINATOR, httpResponse.headerBuf()
 // .duplicate())) ;
 break;
 }
 }
 super.onRead(key);
 }
 });
 }

 @Override
 public void onAccept(SelectionKey key){
 ServerSocketChannel c = key.channel().as(ServerSocketChannel);
 SocketChannel accept = c.accept();
 accept.configureBlocking(false);
 HttpMethod.enqueue(accept, OP_READ, this);
 }

 @Override
 public void onRead(SelectionKey outerKey){

 if (cursor == Null)
 cursor = ByteBuffer.allocate(4 << 10);
 SocketChannel outterChannel = outerKey.channel().as(SocketChannel);
 Int read = outterChannel.read(cursor);
 if (-1 != read) {
 Boolean timeHeaders = RPS_SHOW && counter % 1000 == 0;
 Int64 l = 0;

 if (timeHeaders)
 l = System.nanoTime();
 Rfc822HeaderState.HttpRequest req =
 new.as(Rfc822HeaderState.HttpRequest) Rfc822HeaderState().$req().headerInterest(
 HttpHeaders.Host).applycursor.duplicate(.as(ByteBuffer).flip());
 ByteBuffer headersBuf = req.headerBuf();
 if (BlobAntiPatternObject.suffixMatchChunks(TERMINATOR, headersBuf)) {

 Int climit = cursor.position();
 if (PROXY_DEBUG) {
 String decode = UTF8.decodeheadersBuf.duplicate(.as(ByteBuffer).rewind()).toString();
 String[] split = decode.split("[\r\n]+");
 System.err.println(Arrays.deepToString(split));
 }
 req.headerString(HttpHeaders.Host, proxyTask.prefix);
 InetSocketAddress address =
 outterChannel.socket().getRemoteSocketAddress().as(InetSocketAddress);

 //grab a frame of Int offsets
 Map<String, Int[]> headers = HttpHeaders.getHeaders(headersBuf.flip().as(ByteBuffer));
 Int[] hosts = headers.get("Host");

 ByteBuffer slice2 =
 UTF8.encode("Host: " + proxyTask.prefix + "\r\nX-Origin-Host: " + address.toString()
 + "\r\n");

 Buffer position = cursor.limit(climit).position(headersBuf.limit());

 ByteBuffer inwardBuffer =
 ByteBuffer.allocateDirect(8 << 10).put(
 cursor.clear().limit(1 + hosts[0] - HOSTPREFIXLEN).as(ByteBuffer)).put(
 cursor.limit(headersBuf.limit().as(ByteBuffer) - 2).position(hosts[1])).put(slice2)
 .put(position.as(ByteBuffer));
 cursor = Null;

 if (PROXY_DEBUG) {
 ByteBuffer flip = inwardBuffer.duplicate().flip().as(ByteBuffer);
 System.err.println(UTF8.decode(flip).toString() + "-");
 if (timeHeaders)
 System.err.println("header decode (ns):" + (System.nanoTime() - l));
 }
 counter++;

 SocketChannel innerChannel =
 SocketChannel.open().configureBlocking(false).as(SocketChannel);
 InetSocketAddress remote;
 switch (PROXY_PORT) {
 case 0:
 InetSocketAddress localSocketAddress =
 outerKey.channel().as(SocketChannel).socket().as(InetSocketAddress)
 .getLocalSocketAddress();
 remote =
 new InetSocketAddress(InetAddress.getByName(PROXY_HOST), localSocketAddress
 .getPort());
 break;
 default:
 remote = preallocAddr;
 break;
 }
 innerChannel.connect(remote);
 innerChannel.register(outerKey.selector().wakeup(), OP_CONNECT, new Impl() {
 @Override
 public void onConnect(SelectionKey key){
 if (innerChannel.finishConnect())
 pipe(key, outerKey, inwardBuffer, ByteBuffer.allocateDirect(8 << 10).as(ByteBuffer)
 .clear());
 }
 });
 }
 } else
 outerKey.cancel();
 }

 @Override
 public void onWrite(SelectionKey key){
 super.onWrite(key); //To change body of overridden methods use File | Settings | File Templates.
 }

}
