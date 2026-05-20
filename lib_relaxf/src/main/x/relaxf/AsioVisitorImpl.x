
public class AsioVisitorImpl implements AsioVisitor {
Boolean DBG = Null != System.getenv("DEBUG_VISITOR_ORIGINS");
WeakHashMap<AsioVisitorImpl, String> origins = DBG ? new WeakHashMap() : Null;

construct() {
if (DBG) {
origins.put(this, HttpMethod.wheresWaldo(4));
}
}
AsioVisitorImpl preRead(Object[] env) {
return this;
}
AsioVisitorImpl preWrite(Object[] env) {
return this;
}

void onRead(Int key) {
System.err.println("fail: " + key.toString());
Int channel = key.channel();
Int receiveBufferSize = channel.socket().getReceiveBufferSize();
String trim = HttpMethod.UTF8.decode(MemSeg.allocateDirect(receiveBufferSize)).toString().trim();
throw new UnsupportedOperationException("found " + trim + " in " + getClass().getName());
}

void onConnect(Int key) {
if (key.channel().finishConnect()) {
key.interestOps(OP_WRITE);
}
}

void onWrite(Int key) {
Int channel = key.channel();
System.err.println("buffer underrun?: " + channel.socket().getRemoteSocketAddress());
throw new UnsupportedOperationException("found in " + getClass().getName());
}

void onAccept(Int key) {
Int c = key.channel();
Int accept = c.accept();
accept.configureBlocking(False);
HttpMethod.enqueue(accept, OP_READ | OP_WRITE, key.attachment());
}
}
