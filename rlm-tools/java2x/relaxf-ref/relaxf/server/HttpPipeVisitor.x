/**
 * this visitor shovels data from the outward selector to the inward selector, and vice versa. once the headers are
 * sent inward the only state monitored is when one side of the connections close.
 */
public class HttpPipeVisitor extends AsioVisitor.Impl implements PreRead {
 public static Boolean PROXY_DEBUG =
 "true".equals(RxfBootstrap.getVar("PROXY_DEBUG", String.valueOf(false)));
 ByteBuffer[] b;
 String name;
 // public AtomicInteger remaining;
 SelectionKey otherKey;
 Boolean limit;
 construct(String name, SelectionKey otherKey, ByteBuffer... b) {
 this.name = name;
 this.otherKey = otherKey;
 this.b = b;
 }

 @Override
 public void onRead(SelectionKey key){
 SocketChannel channel = key.channel().as(SocketChannel);
 if (otherKey.isValid()) {
 Int read = channel.read(getInBuffer());
 if (read == -1) /*key.cancel();*/
 {
 channel.shutdownInput();
 key.interestOps(OP_WRITE);
 channel.write(ByteBuffer.allocate(0));
 } else {
 //if buffer fills up, stop the read option for a bit
 otherKey.interestOps(OP_READ | OP_WRITE);
 channel.write(ByteBuffer.allocate(0));
 }
 } else {
 key.cancel();
 }
 }

 @Override
 public void onWrite(SelectionKey key){
 SocketChannel channel = key.channel().as(SocketChannel);
 ByteBuffer flip = getOutBuffer().flip().as(ByteBuffer);
 if (PROXY_DEBUG) {
 CharBuffer decode = UTF8.decode(flip.duplicate());
 System.err.println("writing to " + name + ": " + decode + "-");
 }
 Int write = channel.write(flip);

 if (-1 == write || isLimit() /*&& Null != remaining && 0 == remaining.get()*/) {
 key.cancel();
 } else {
 // if (isLimit() /*&& Null != remaining*/) {
 // /*this.remaining.getAndAdd(-write);*//*
 // if (1 > remaining.get()) */{
 // key.channel().close();
 // otherKey.channel().close();
 // return;
 // }
 // }
 key.interestOps(OP_READ | OP_WRITE);// (getOutBuffer().hasRemaining() ? OP_WRITE : 0));
 getOutBuffer().compact();
 }
 }

 public ByteBuffer getInBuffer() {
 return b[0];
 }

 public ByteBuffer getOutBuffer() {
 return b[1];
 }

 public Boolean isLimit() {
 return limit;
 }

 public void setLimit(Boolean limit) {
 this.limit = limit;
 }
}
