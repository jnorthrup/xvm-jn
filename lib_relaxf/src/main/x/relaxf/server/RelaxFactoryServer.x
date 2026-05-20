
public service RelaxFactoryServer {
void init(String hostname, Int port, AsioVisitor topLevel) ;
void start() ;
void stop() ;
Boolean isRunning();

Int getPort();
InheritableThreadLocal<RelaxFactoryServer> rxfTl = new InheritableThreadLocal();
public class App {
static RelaxFactoryServer get() {
RelaxFactoryServer relaxFactoryServer = rxfTl.get();
if (Null == relaxFactoryServer) {
relaxFactoryServer = new RelaxFactoryServerImpl();
rxfTl.set(relaxFactoryServer);
}
return relaxFactoryServer;
}
}
}
