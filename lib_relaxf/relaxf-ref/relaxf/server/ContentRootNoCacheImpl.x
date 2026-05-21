public class ContentRootNoCacheImpl extends ContentRootImpl {

 public static Pattern NOCACHE_PATTERN = Pattern.compile(".*[.]nocache[.](js|html)$");

 @Override
 public void onWrite(SelectionKey key){
 req.headerStrings().put(HttpHeaders.Expires.getHeader(),
 DateHeaderParser.RFC1123.getFormat().format(new Date()));
 super.onWrite(key);
 }
}
