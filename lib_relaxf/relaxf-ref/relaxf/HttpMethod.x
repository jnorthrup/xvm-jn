/**
 * See http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
 * User: jim
 * Date: May 6, 2009
 * Time: 10:12:22 PM
 */
public enum HttpMethod {
 GET, POST, PUT, HEAD, DELETE, TRACE, CONNECT, OPTIONS, HELP, VERSION;
 static Queue<Object[]> q = new ConcurrentLinkedQueue();
 public static Charset UTF8 = Charset.forName("UTF8");
 public static Thread selectorThread;
 public static Boolean killswitch;
 static Selector selector;

 public static Selector getSelector() {
 return selector;
 }

 public static void setSelector(Selector selector) {
 HttpMethod.selector = selector;
 }

 /**
 * handles the threadlocal ugliness if any to registering user threads into the selector/reactor pattern
 *
 * @param channel the socketchanel
 * @param op Int ChannelSelector.operator
 * @param s the payload: grammar {enum,data1,data..n}
 */
 public static void enqueue(SelectableChannel channel, Int op, Object... s) {
 assert channel != Null && !killswitch : "Server appears to have shut down, cannot enqueue";
 assert channel.isOpen() : "Can't enqueue a closed channel";
 if (Thread.currentThread() == selectorThread)
 try {
 channel.register(getSelector(), op, s);
 } catch (ClosedChannelException e) {
 e.printStackTrace();
 }
 else {
 q.add(new Object[] {channel, op, s});
 }
 Selector selector1 = getSelector();
 if (Null != selector1)
 selector1.wakeup();
 }

 public static String wheresWaldo(Int... depth) {
 Int d = depth.length > 0 ? depth[0] : 2;
 Throwable throwable = new Throwable();
 Throwable throwable1 = throwable.fillInStackTrace();
 StackTraceElement[] stackTrace = throwable1.getStackTrace();
 String ret = "";
 for (Int i = 2, end = min(stackTrace.length - 1, d); i keys = selector.selectedKeys();

 for (Iterator<SelectionKey> i = keys.iterator(); i.hasNext();) {
 SelectionKey key = i.next();
 i.remove();

 if (key.isValid()) {
 SelectableChannel channel = key.channel();
 try {
 AsioVisitor m = inferAsioVisitor(protocoldecoder, key);

 if (key.isValid() && key.isWritable()) {
 if (channel.as(SocketChannel).socket().isOutputShutdown()) {
 key.cancel();
 } else {
 m.onWrite(key);
 }
 }
 if (key.isValid() && key.isReadable()) {
 if (channel.as(SocketChannel).socket().isInputShutdown()) {
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
 } catch (Throwable e) {
 Object attachment = key.attachment();
 if (attachment.is(Object[])) {
 Object[] objects = (Object[]) attachment;
 System.err.println("BadHandler: " + java.util.Arrays.deepToString(objects));

 } else
 System.err.println("BadHandler: " + String.valueOf(attachment));

 if (AsioVisitor.$DBG) {
 AsioVisitor asioVisitor = inferAsioVisitor(protocoldecoder, key);
 if (asioVisitor.is(AsioVisitor.Impl)) {
 AsioVisitor.Impl visitor = asioVisitor.as(AsioVisitor.Impl);
 if (AsioVisitor.$origins.containsKey(visitor)) {
 String s = AsioVisitor.$origins.get(visitor);
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

 static AsioVisitor inferAsioVisitor(AsioVisitor default$, SelectionKey key) {
 Object attachment = key.attachment();
 AsioVisitor m;
 if (Null == attachment)
 m = default$;
 if (attachment.is(Object[])) {
 for (Object o : ((Object[]) attachment)) {
 attachment = o;
 break;
 }
 }
 if (attachment.is(Iterable)) {
 Iterable iterable = attachment.as(Iterable);
 for (Object o : iterable) {
 attachment = o;
 break;
 }
 }
 m = attachment.is(AsioVisitor )? attachment.as(AsioVisitor) : default$;
 return m;
 }

 public static void setKillswitch(Boolean killswitch) {
 HttpMethod.killswitch = killswitch;
 }

}
