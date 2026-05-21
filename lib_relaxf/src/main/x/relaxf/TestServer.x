/**
 * Test server entry point for lib_relaxf.
 * Wires up RelaxFactoryServerImpl with ProtocolMethodDispatch to serve
 * static files from the configured content root (default: ./)
 *
 * Usage:
 *   RXF_SERVER_CONTENT_ROOT=/tmp/files ./gradlew :xdk:lib-relaxf:runXtc --module=lib_relaxf.xtclang.org --method=main
 *
 * Or with args:
 *   ./gradlew :xdk:lib-relaxf:runXtc --module=lib_relaxf.xtclang.org --method=main -- 8080 /tmp/files
 */
class TestServer {
    static void main(String[] args) {
        String hostname = "0.0.0.0";
        Int port = 8080;
        String contentRoot = "./";

        if (args.size >= 1) {
            port = Int.parse(args[0]);
        }
        if (args.size >= 2) {
            contentRoot = args[1];
        }

        System.setProperty("rxf.server.content.root", contentRoot);
        System.out.println("content root: " + contentRoot);

        ProtocolMethodDispatch dispatch = new ProtocolMethodDispatch();
        RelaxFactoryServer server = RelaxFactoryServer.get();
        server.init(hostname, port, dispatch);
        System.out.println("starting server on " + hostname + ":" + port + " ...");
        server.start();
    }
}