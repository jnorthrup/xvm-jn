/**
 * Off-heap zero-copy memory segment. Data flows without crossing service boundaries.
 */
public service MemSeg(Int size) {
    Byte get(Int offset);
    void put(Int offset, Byte value);
    Int size();
    void close();
}
