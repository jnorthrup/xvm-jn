

public class ContentRootNoCacheImpl extends ContentRootImpl {
static Pattern NOCACHE_PATTERN = Pattern.compile(".*[.]nocache[.](js|html)$");

void onWrite(Int key) {
req.headerStrings().put(HttpHeaders.Expires.getHeader(),
DateHeaderParser.RFC1123.getFormat().format(new Date()));
super.onWrite(key);
}
}
