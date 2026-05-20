
public enum HttpMethod {
GET, POST, PUT, HEAD, DELETE, TRACE, CONNECT, OPTIONS, HELP, VERSION;
static Queue<Object[]> q = new ConcurrentLinkedQueue();
static Charset UTF8 = Charset.forName("UTF8");
static Thread selectorThread;
static Boolean killswitch;
static Selector selector;
static Selector getSelector() {
return selector;
}
static void setSelector(Selector selector) {
HttpMethod.selector = selector;
}

static void enqueue(Int channel, Int op, Object[] s) {
assert channel != Null && !killswitch : "Server appears to have shut down, cannot enqueue";
assert channel.isOpen() : "Can't enqueue a closed channel";
if (Thread.currentThread() == selectorThread) {
try {
channel.register(getSelector(), op, s);
} catch (ClosedChannelException e) {
e.printStackTrace();
}
} else {
q.add([channel, op, s]);
}
Selector selector1 = getSelector();
if (Null != selector1) {
selector1.wakeup();
}
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
setSelector(Selector.open());
selectorThread = Thread.currentThread();
for (String s : a) {
Int timeoutMax = 1024;
Int timeout = 1;
while (!killswitch) {
while (!q.empty) {
Object[] arr = q.remove();
Int x = arr[0];
Selector sel = getSelector();
Integer op = arr[1];
Object att = arr[2];

try {
x.configureBlocking(False);
Int register = x.register(sel, op, att);
assert Null != register;
} catch (Exception e) {
e.printStackTrace();
}
}
Int select = selector.select(timeout);
timeout = 0 == select ? min(timeout << 1, timeoutMax) : 1;
if (0 != select) {
innerloop(protocoldecoder);
}
}
}
}
static void innerloop(AsioVisitor protocoldecoder) {
Set<Int> keys = selector.selectedKeys();
for (Iterator<Int> i = keys.iterator(); i.hasNext();) {
Int key = i.next();
i.remove();
if (key.isValid()) {
Int channel = key.channel();
try {
AsioVisitor m = inferAsioVisitor(protocoldecoder, key);
if (key.isValid() && key.isWritable()) {
if (channel.socket().isOutputShutdown()) {
key.cancel();
} else {
m.onWrite(key);
}
}
if (key.isValid() && key.isReadable()) {
if (channel.socket().isInputShutdown()) {
key.cancel();
} else {
m.onRead(key);
}
}
if (key.isValid() && key.isAcceptable()) {
m.onAccept(key);
}
if (key.isValid() && key.isConnectable()) {
m.onConnect(key);
}
} catch (Exception e) {
Object attachment = key.attachment();
if (attachment.is(Object[])) {
Object[] objects = attachment;
System.err.println("BadHandler: " + java.util.Arrays.deepToString(objects));
} else {
System.err.println("BadHandler: " + String.valueOf(attachment));
}
if (AsioVisitorImpl.DBG) {
AsioVisitor asioVisitor = inferAsioVisitor(protocoldecoder, key);
if (asioVisitor.is(AsioVisitorImpl)) {
AsioVisitorImpl visitor = asioVisitor;
if (AsioVisitorImpl.origins.containsKey(visitor)) {
String s = AsioVisitorImpl.origins.get(visitor);
System.err.println("origin" + s);
}
}
}
e.printStackTrace();
key.attach(Null);
channel.close();
}
}
}
}
static AsioVisitor inferAsioVisitor(AsioVisitor defaultVisitor, Int key) {
Object attachment = key.attachment();
AsioVisitor m;
if (Null == attachment) {
m = defaultVisitor;
} else {
if (attachment.is(Object[])) {
for (Object o : attachment) {
attachment = o;
break;
}
}
if (attachment.is(Iterable)) {
Iterable iterable = attachment;
for (Object o : iterable) {
attachment = o;
break;
}
}
if (attachment.is(AsioVisitor)) {
m = attachment;
} else {
m = defaultVisitor;
}
}
return m;
}
static void setKillswitch(Boolean killswitch) {
HttpMethod.killswitch = killswitch;
}
}
