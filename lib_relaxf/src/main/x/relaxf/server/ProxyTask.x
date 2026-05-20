

public class ProxyTask implements Runnable {
String prefix;
String[] proxyPorts;

void run() {
try {
for (String proxyPort : proxyPorts) {
HttpMethod.enqueue(Int.open().bind(
new InetSocketAddress(Int.parse(proxyPort)), 4096).setOption(
StandardSocketOptions.SO_REUSEADDR, True).configureBlocking(False),
Int.OP_ACCEPT, new ProxyDaemon(this));
}
} catch (Exception e) {
e.printStackTrace();
}
}
static void main(String[] args) {

BlobAntiPatternObject.getEXECUTOR_SERVICE().submit(new ProxyTask() {
construct() {
proxyPorts = args;
}
});
}
}
