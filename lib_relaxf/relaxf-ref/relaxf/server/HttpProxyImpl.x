import static one.xio.HttpHeaders.Content$2dLength;
/**
 * User: jim
 * Date: 6/4/12
 * Time: 1:40 AM
 */
public class HttpProxyImpl extends Impl {
 public static String[] HEADER_INTEREST = staticHeaderStrings(Content$2dLength);
 Pattern passthroughExpr;
 construct(Pattern passthroughExpr) {
 this.passthroughExpr = passthroughExpr;
 }

 @Override
 public void onWrite(SelectionKey browserKey){

 browserKey.selector().wakeup();
 browserKey.interestOps(OP_READ);
 String path;
 Rfc822HeaderState state = Null;
 for (Object o : Arrays.asList(browserKey.attachment())) {
 if (o.is(Rfc822HeaderState)) {
 ActionBuilder.get().state(state = o.as(Rfc822HeaderState));
 break;
 }
 }
 if (Null == state) {
 throw new Error("this GET proxy requires " + Rfc822HeaderState.class.getCanonicalName()
 + " in " + SelectionKey.class.getCanonicalName() + ".attachments :(");
 }

 path = state.pathResCode();
 Matcher matcher = passthroughExpr.matcher(path);
 if (matcher.matches()) {
 String link = matcher.group(1);

 String req =
 "GET " + link + " HTTP/1.1\r\n" + "Accept: image/*, text/*\r\n" + "Connection: close\r\n"
 + "\r\n";

 SocketChannel couchConnection = BlobAntiPatternObject.createCouchConnection();
 RelaxFactoryServerImpl.enqueue(couchConnection, OP_CONNECT | OP_WRITE, new Impl() {
 @Override
 public void onRead(SelectionKey couchKey){
 SocketChannel channel = couchKey.channel().as(SocketChannel);
 ByteBuffer dst =
 ByteBuffer.allocateDirect(BlobAntiPatternObject.getReceiveBufferSize());
 Int read = channel.read(dst);
 Rfc822HeaderState proxyState = new Rfc822HeaderState(HEADER_INTEREST);
 Int total = Integer.parseInt(proxyState.headerString(Content$2dLength));
 SocketChannel browserChannel = browserKey.channel().as(SocketChannel);
 try {

 Int write = browserChannel.write(dst.rewind().as(ByteBuffer));
 } catch (IOException e) {
 couchConnection.close();
 return;
 }

 couchKey.selector().wakeup();
 couchKey.interestOps(OP_READ).attach(new Impl() {
 ByteBuffer sharedBuf =
 ByteBuffer.allocateDirect(Math.min(total, BlobAntiPatternObject
 .getReceiveBufferSize()));
 Impl browserSlave = new Impl() {
 @Override
 public void onWrite(SelectionKey key){
 try {
 Int write = browserChannel.write(dst);
 if (!dst.hasRemaining() && remaining == 0)
 browserChannel.close();
 browserKey.selector().wakeup();
 browserKey.interestOps(0);
 couchKey.selector().wakeup();
 couchKey.interestOps(OP_READ).selector().wakeup();
 } catch (Exception e) {
 browserChannel.close();
 } finally {
 }
 }
 };
 public Int remaining = total;

 {
 browserKey.attach(browserSlave);
 }

 @Override
 public void onRead(SelectionKey couchKey){

 if (browserKey.isValid() && remaining != 0) {
 dst.compact();//threadsafety guarantee by monothreaded selector

 remaining -= couchConnection.read(dst);
 dst.flip();
 couchKey.selector().wakeup();
 couchKey.interestOps(0);
 browserKey.selector().wakeup();
 browserKey.interestOps(OP_WRITE).selector().wakeup();

 } else {
 BlobAntiPatternObject.recycleChannel(couchConnection);
 }
 }
 });
 }

 @Override
 public void onWrite(SelectionKey couchKey){
 couchConnection.write(UTF8.encode(req));
 couchKey.selector().wakeup();
 couchKey.interestOps(OP_READ);
 }
 });
 }
 }

}
