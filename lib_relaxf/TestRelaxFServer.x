/**
 * RelaxFactory web server test.
 *
 * Serves static files from the current directory on port 8080.
 * Requires lib_relaxf to be compiled first.
 *
 * Run with:
 *     xec -L build/xtc/main/lib:../lib_net/build/xtc/main/lib:../lib_collections/build/xtc/main/lib:../lib_aggregate/build/xtc/main/lib:../lib_convert/build/xtc/main/lib:../lib_sec/build/xtc/main/lib:../lib_crypto/build/xtc/main/lib:../lib_json/build/xtc/main/lib:../lib_xunit/build/xtc/main/lib:../javatools_bridge/build/xtc/main/lib:../lib_xunit_engine/build/xtc/main/lib:../lib_ecstasy/build/xtc/main/lib:../lib_web/build/xtc/main/lib build/xtc/main/lib/lib_relaxf.xtc
 */
module TestRelaxFServer {
    import relaxf.xtclang.org.server.ProtocolMethodDispatch;
    import relaxf.xtclang.org.server.RelaxFactoryServer;

    void run() {
        String hostname = "0.0.0.0";
        Int port = 8080;

        ProtocolMethodDispatch dispatch = new ProtocolMethodDispatch();
        RelaxFactoryServer server = RelaxFactoryServer.get();
        server.init(hostname, port, dispatch);
        server.start();
    }
}