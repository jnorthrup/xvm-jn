

public class HttpPipeVisitor extends AsioVisitorImpl implements PreRead {
static Boolean PROXY_DEBUG =
"True" == RxfBootstrap.getVar("PROXY_DEBUG", String.valueOf(False));
MemSeg[] b;
String name;

Int otherKey;
Boolean limit;
construct (String name, Int otherKey, MemSeg[] b) {
this.name = name;
this.otherKey = otherKey;
this.b = b;
}

void onRead(Int key) {
Int channel = key.channel();
if (otherKey.isValid()) {
Int read = channel.read(getInBuffer());
if (read == -1) {
    key.cancel();
} else {
    otherKey.interestOps(OP_READ | OP_WRITE);
    channel.write(MemSeg.allocate(0));
}
} else {
key.cancel();
}
}

void onWrite(Int key) {
Int channel = key.channel();
MemSeg flip = getOutBuffer().flip();
if (PROXY_DEBUG) {
CharBuffer decode = UTF8.decode(flip.duplicate());
System.err.println("writing to " + name + ": " + decode + "-");
}
Int write = channel.write(flip);
if (-1 == write || isLimit()) {
key.cancel();
} else {

key.interestOps(OP_READ | OP_WRITE);
getOutBuffer().compact();
}
}
MemSeg getInBuffer() {
return b[0];
}
MemSeg getOutBuffer() {
return b[1];
}
Boolean isLimit() {
return limit;
}
void setLimit(Boolean limit) {
this.limit = limit;
}
}
