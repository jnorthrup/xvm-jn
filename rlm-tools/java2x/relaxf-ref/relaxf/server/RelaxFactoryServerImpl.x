public class RelaxFactoryServerImpl implements RelaxFactoryServer {

 Int port = 8080;
 AsioVisitor topLevel;
 InetAddress hostname;

 ServerSocketChannel serverSocketChannel;

 volatile Boolean isRunning;

 /**
 * handles the threadlocal ugliness if any to registering user threads into the selector/reactor pattern
 *
 * @param channel the socketchanel
 * @param op Int ChannelSelector.operator
 * @param s the payload: grammar {enum,data1,data..n}
 * @throws java.nio.channels.ClosedChannelException
 *
 */
 public static void enqueue(SelectableChannel channel, Int op, Object... s){
 HttpMethod.enqueue(channel, op, s);
 }

 public static String wheresWaldo(Int... depth) {
 Int d = depth.length > 0 ? depth[0] : 2;
 Throwable throwable = new Throwable();
 Throwable throwable1 = throwable.fillInStackTrace();
 StackTraceElement[] stackTrace = throwable1.getStackTrace();
 String ret = "";
 for (Int i = 2, end = min(stackTrace.length - 1, d); i <= end; i++) {
 StackTraceElement stackTraceElement = stackTrace[i];
 ret +=
 "\tat " + stackTraceElement.getClassName() + "." + stackTraceElement.getMethodName()
 + "(" + stackTraceElement.getFileName() + ":" + stackTraceElement.getLineNumber()
 + ")\n";

 }
 return ret;
 }

 public static void init(AsioVisitor protocoldecoder, String... a){
 HttpMethod.init(protocoldecoder, a);
 }

 public void setPort(Int port) {
 this.port = port;
 }

 @Override
 public void init(String hostname, Int port, AsioVisitor topLevel){
 assert this.topLevel == Null && this.serverSocketChannel == Null : "Can't call init twice";
 this.topLevel = topLevel;
 this.setPort(port);
 this.hostname = InetAddress.getByName(hostname);
 }

 @Override
 public void start(){
 assert serverSocketChannel == Null : "Can't start already started server";

 isRunning = true;
 try {
 serverSocketChannel = ServerSocketChannel.open();
 InetSocketAddress addr = new InetSocketAddress(hostname, getPort());
 serverSocketChannel.socket().bind(addr);
 setPort(serverSocketChannel.socket().getLocalPort());
 System.out.println(hostname.getHostAddress() + ":" + getPort());
 serverSocketChannel.configureBlocking(false);

 enqueue(serverSocketChannel, OP_ACCEPT, topLevel);
 init(topLevel);
 } finally {
 isRunning = false;
 }
 }

 @Override
 public Int getPort() {
 return port;
 }

 @Override
 public void stop(){
 HttpMethod.killswitch = true;
 serverSocketChannel.close();
 }

 @Override
 public Boolean isRunning() {
 return isRunning;
 }

}
