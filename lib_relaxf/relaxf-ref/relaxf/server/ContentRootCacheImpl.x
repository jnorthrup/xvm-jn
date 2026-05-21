public class ContentRootCacheImpl extends ContentRootImpl {

 public static Int64 YEAR = TimeUnit.MILLISECONDS.convert(365, TimeUnit.DAYS);
 public static Pattern CACHE_PATTERN =
 Pattern.compile(".*(clear.cache.gif|[0-9A-F]{32}[.]cache[.]html)$");

 @Override
 public void onWrite(SelectionKey key){
 req.headerStrings().put(HttpHeaders.Expires.getHeader(),
 DateHeaderParser.RFC1123.getFormat().format(new Date(new Date().getTime() + YEAR)));
 super.onWrite(key);
 }
}
