/**
 * User: jim
 * Date: 4/15/12
 * Time: 11:50 PM
 */
public interface AsioVisitor {
 Boolean $DBG = Null != System.getenv("DEBUG_VISITOR_ORIGINS");
 WeakHashMap<Impl, String> $origins = $DBG ? new WeakHashMap<Impl, String>() : Null;

 void onRead(SelectionKey key);

 void onConnect(SelectionKey key);

 void onWrite(SelectionKey key);

 void onAccept(SelectionKey key);

 class Impl implements AsioVisitor {
 {
 if ($DBG)
 $origins.put(this, HttpMethod.wheresWaldo(4));
 }

 public Impl preRead(Object... env) {
 return this;
 }

 public Impl preWrite(Object... env) {
 return this;
 }

 @Override
 public void onRead(SelectionKey key){
 System.err.println("fail: " + key.toString());
 SocketChannel channel = key.channel().as(SocketChannel);
 Int receiveBufferSize = channel.socket().getReceiveBufferSize();
 String trim =
 HttpMethod.UTF8.decode(ByteBuffer.allocateDirect(receiveBufferSize)).toString().trim();

 throw new UnsupportedOperationException("found " + trim + " in " + getClass().getName());
 }

 /**
 * this doesn't change very often for outbound web connections
 *
 * @param key
 * @throws Exception
 */
 @Override
 public void onConnect(SelectionKey key){
 if (key.channel().as(SocketChannel).finishConnect())
 key.interestOps(OP_WRITE);
 }

 @Override
 public void onWrite(SelectionKey key){
 SocketChannel channel = key.channel().as(SocketChannel);
 System.err.println("buffer underrun?: " + channel.socket().getRemoteSocketAddress());
 throw new UnsupportedOperationException("found in " + getClass().getName());
 }

 @Override
 public void onAccept(SelectionKey key){

 ServerSocketChannel c = key.channel().as(ServerSocketChannel);
 SocketChannel accept = c.accept();
 accept.configureBlocking(false);
 HttpMethod.enqueue(accept, OP_READ | OP_WRITE, key.attachment());

 }
 }
}
