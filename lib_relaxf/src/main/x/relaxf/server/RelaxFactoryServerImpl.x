
public class RelaxFactoryServerImpl implements RelaxFactoryServer {
Int port = 8080;
AsioVisitor topLevel;
InetAddress hostname;
Int serverSocketChannel;
Boolean isRunning;

static void enqueue(Int channel, Int op, Object[] s)
{
HttpMethod.enqueue(channel, op, s);
}
static String wheresWaldo(Int[] depth) {
Int d = depth.size > 0 ? depth[0] : 2;
Throwable throwable = new Throwable();
Throwable throwable1 = throwable.fillInStackTrace();
StackTraceElement[] stackTrace = throwable1.getStackTrace();
String ret = "";
for (Int i = 2, end = min(stackTrace.size - 1, d); i <= end; i++) {
StackTraceElement stackTraceElement = stackTrace[i];
ret +=
"\tat " + stackTraceElement.getClassName() + "." + stackTraceElement.getMethodName()
+ "(" + stackTraceElement.getFileName() + ":" + stackTraceElement.getLineNumber()
+ ")\n";
}
return ret;
}
static void init(AsioVisitor protocoldecoder, String[] a) {
HttpMethod.init(protocoldecoder, a);
}
void setPort(Int port) {
this.port = port;
}

void init(String hostname, Int port, AsioVisitor topLevel) {
assert this.topLevel == Null && this.serverSocketChannel == Null : "Can't call init twice";
this.topLevel = topLevel;
this.setPort(port);
this.hostname = InetAddress.getByName(hostname);
}

void start() {
assert serverSocketChannel == Null : "Can't start already started server";
isRunning = True;
try {
serverSocketChannel = Int.open();
InetSocketAddress addr = new InetSocketAddress(hostname, getPort());
serverSocketChannel.socket().bind(addr);
setPort(serverSocketChannel.socket().getLocalPort());
System.out.println(hostname.getHostAddress() + ":" + getPort());
serverSocketChannel.configureBlocking(False);
enqueue(serverSocketChannel, OP_ACCEPT, topLevel);
init(topLevel);
} finally {
isRunning = False;
}
}

Int getPort() {
return port;
}

void stop() {
HttpMethod.killswitch = True;
serverSocketChannel.close();
}

Boolean isRunning() {
return isRunning;
}
}
