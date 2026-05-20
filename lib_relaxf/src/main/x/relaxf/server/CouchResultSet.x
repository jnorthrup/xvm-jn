
public class CouchResultSet<K, V> {
Int totalRows;
Int offset;
static class tuple<K, V> {
String id;
K key;
V value;
Map<String, Object> doc;
}
List<tuple<K, V>> rows;
}
