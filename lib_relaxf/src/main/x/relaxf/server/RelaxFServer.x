/**
 * RelaxFactory server entry point.
 * Ported from Colin Alworth's production code (niloc132/master, commit 99544ab).
 */
public service RelaxFServer {
    void init(String hostname, Int port, EventLoop loop);
    void start();
    void stop();
    
    @RO Boolean running;
    @RO Int port;
}
