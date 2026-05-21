/**
 * User: jim
 * Date: 5/16/12
 * Time: 7:56 PM
 */
public class CouchResultSet<K, V> {

 public Int64 totalRows;
 public Int64 offset;

 public static class tuple<K, V> {
 public String id;
 public K key;
 public V value;
 public Map doc;
 }

 public List<tuple<K, V>> rows;
}
