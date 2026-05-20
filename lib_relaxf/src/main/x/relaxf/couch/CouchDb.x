/**
 * CouchDB service interface. Ported from Colin Alworth's production code.
 * CouchDB is a pure REST API — all operations are HTTP calls.
 */
public service CouchDb {
    String baseUrl;

    String find(String db, String docId);
    String persist(String db, Byte[] doc);
}