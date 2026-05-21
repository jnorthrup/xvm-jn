/**
 * confers traits on an oo platform...
 * <p/>
 * CouchDriver defines an interface and a method for each {@link CouchMetaDriver } enum attribute. presently the generator does
 * not wire that interface up anywhere but the inner classes of the interface use this enum for slotted method dispatch.
 * <p/>
 * the fluent interface is carried in threadlocal variables from step to step. the visit() method cracks these open and
 * inserts them as the apropriate state for lower level visit(builder1...buildern) method
 * <p/>
 * <h2>{@link one.xio.AsioVisitor} visitor sub-threads in threadpools must be one of:</h2><ol>
 * <li>inner classes using the <u>final</u> paramters passed in
 * via {@link #visit(rxf.server.DbKeysBuilder, rxf.server.ActionBuilder)}</li>
 * <li>fluent class interface agnostic(highly unlikely)</li>
 * <li>arduously carried in (same as first option but not as clean as inner class refs)</li>
 * </ol>
 * <p/>
 * <p/>
 * <ul>DSEL addendum:
 * <li>to() - setup the request: provide early access to the header state to tweak whatever you want. This can then be used after fire() to read out the header state from the response
 * <li> fire() - execution of the visitor, access to results, future, (errors?). If results is Null, check error. If you use future, its your own damn problem
 * </ul>
 * User: jim
 * Date: 5/24/12
 * Time: 3:09 PM
 */
@SuppressWarnings( {"RedundantCast"})
public enum CouchMetaDriver {

 @DbTask( {tx, oneWay})
 @DbKeys( {db})
 DbCreate {
 public ByteBuffer visit(DbKeysBuilder dbKeysBuilder, ActionBuilder actionBuilder){
 AtomicReference<ByteBuffer> payload = new AtomicReference<ByteBuffer>();
 Phaser phaser = new Phaser(2);
 // Rfc822HeaderState state = actionBuilder.state();
 // ByteBuffer header = state.$req().method(PUT).path("/" + dbKeysBuilder.get(db))
 // .headerString(Content$2dLength, "0")
 // .asRequestHeaderByteBuffer();
 SocketChannel channel = createCouchConnection();
 enqueue(channel, OP_WRITE | OP_CONNECT, new Impl() {
 // *******************************
 // pathological buffersize traits
 // *******************************

 String db = dbKeysBuilder.get(etype.db).as(String);
 String id = dbKeysBuilder.get(docId).as(String);
 HttpRequest request = actionBuilder.state().$req();
 HttpResponse response;
 ByteBuffer header = request.method(PUT).path("/" + db).as(ByteBuffer)
 // .headerString(Content$2dLength, "0")
 .as(ByteBuffer.class);

 public void onWrite(SelectionKey key){
 Int write = channel.write(header);
 assert !header.hasRemaining();
 header.clear();
 response = request.headerInterest(STATIC_JSON_SEND_HEADERS).$res();

 key.interestOps(OP_READ);/*WRITE-READ implicit turnaround in 1xio won't need .selector().wakeup()*/
 }

 ByteBuffer cursor;

 public void onRead(SelectionKey key){
 if (Null == cursor) {
 //geometric, vulnerable to dev/Null if not max'd here.
 header =
 Null == header ? ByteBuffer.allocateDirect(getReceiveBufferSize()) : header
 .hasRemaining() ? header : ByteBuffer.allocateDirect(header.capacity() * 2)
 .put(header.flip().as(ByteBuffer));

 Int read = channel.read(header);
 ByteBuffer flip = header.duplicate().flip().as(ByteBuffer);
 response.apply(flip.as(ByteBuffer));

 if (BlobAntiPatternObject.suffixMatchChunks(HEADER_TERMINATOR, response.headerBuf())) {
 cursor = flip.slice().as(ByteBuffer);
 header = Null;

 if (DEBUG_SENDJSON) {
 System.err.println(deepToString(response.statusEnum(), response, UTF8
 .decodecursor.duplicate(.as(ByteBuffer).rewind())));
 }

 HttpStatus httpStatus = response.statusEnum();
 switch (httpStatus) {
 case $200:
 case $201:
 Int remaining = Integer.parseInt(response.headerString(Content$2dLength));

 if (remaining == cursor.remaining()) {
 deliver();
 } else {
 cursor = ByteBuffer.allocateDirect(remaining).put(cursor);
 }
 break;
 default: //error
 phaser.forceTermination();
 channel.close();
 }
 }
 } else {
 Int read = channel.read(cursor);
 switch (read) {
 case -1:
 phaser.forceTermination();

 channel.close();
 return;
 }
 if (!cursor.hasRemaining()) {
 cursor.flip();
 deliver();
 }
 }
 }

 void deliver() {
 payload.set(cursor);
 recycleChannel(channel);
 phaser.arrive();
 }
 });
 try {
 phaser.awaitAdvanceInterruptibly(phaser.arrive(), REALTIME_CUTOFF, REALTIME_UNIT);
 } catch (Exception e) {
 if (DEBUG_SENDJSON) {
 System.err.println("!!! " + deepToString(this, e) + "\n\tfrom");
 dbKeysBuilder.trace().printStackTrace();
 }
 }
 return payload.get();
 }

 },
 @DbTask( {tx, oneWay})
 @DbKeys( {db})
 DbDelete {
 public ByteBuffer visit(DbKeysBuilder dbKeysBuilder, ActionBuilder actionBuilder){
 AtomicReference<ByteBuffer> payload = new AtomicReference<ByteBuffer>();
 Phaser phaser = new Phaser(2);

 SocketChannel channel = createCouchConnection();

 enqueue(channel, OP_WRITE | OP_CONNECT, new Impl() {
 HttpRequest request = actionBuilder.state().$req();
 ByteBuffer header =
 request.method(DELETE).pathResCode("/" + dbKeysBuilder.get(db).as(ByteBuffer)).as(
 ByteBuffer.class);
 ByteBuffer cursor;
 public HttpResponse response;

 public void onWrite(SelectionKey key){
 Int write = channel.write(header);
 assert !header.hasRemaining();
 header.clear();
 response = request.headerInterest(STATIC_JSON_SEND_HEADERS).$res();

 key.interestOps(OP_READ);/*WRITE-READ implicit turnaround in 1xio won't need .selector().wakeup()*/
 }

 public void onRead(SelectionKey key){
 if (Null == cursor) {
 //geometric, vulnerable to dev/Null if not max'd here.
 header =
 Null == header ? ByteBuffer.allocateDirect(getReceiveBufferSize()) : header
 .hasRemaining() ? header : ByteBuffer.allocateDirect(header.capacity() * 2)
 .put(header.flip().as(ByteBuffer));

 Int read = channel.read(header);
 ByteBuffer flip = header.duplicate().flip().as(ByteBuffer);
 response.apply(flip.as(ByteBuffer));

 if (BlobAntiPatternObject.suffixMatchChunks(HEADER_TERMINATOR, response.headerBuf())) {
 cursor = flip.slice().as(ByteBuffer);
 header = Null;

 if (DEBUG_SENDJSON) {
 System.err.println(deepToString(response.statusEnum(), response, UTF8
 .decodecursor.duplicate(.as(ByteBuffer).rewind())));
 }

 HttpStatus httpStatus = response.statusEnum();
 switch (httpStatus) {
 case $200:
 Int remaining = Integer.parseInt(response.headerString(Content$2dLength));

 if (remaining == cursor.remaining()) {
 deliver();
 } else {
 cursor = ByteBuffer.allocateDirect(remaining).put(cursor);
 }
 break;
 default: //error
 phaser.forceTermination();
 channel.close();
 }
 }
 } else {
 Int read = channel.read(cursor);
 switch (read) {
 case -1:
 phaser.forceTermination();

 channel.close();
 return;
 }
 if (!cursor.hasRemaining()) {
 cursor.flip();
 deliver();
 }
 }
 }

 void deliver() {
 recycleChannel(channel);
 payload.set(cursor);
 phaser.arrive();
 }
 });
 try {
 phaser.awaitAdvanceInterruptibly(phaser.arrive(), REALTIME_CUTOFF, REALTIME_UNIT);
 } catch (Exception e) {
 if (DEBUG_SENDJSON) {
 System.err.println("!!! " + deepToString(this, e) + "\n\tfrom");
 dbKeysBuilder.trace().printStackTrace();
 }
 }
 return payload.get();
 }

 },

 @DbTask( {pojo, future, json})
 @DbKeys( {db, docId})
 DocFetch {
 public ByteBuffer visit(DbKeysBuilder dbKeysBuilder, ActionBuilder actionBuilder){
 AtomicReference<ByteBuffer> payload = new AtomicReference<ByteBuffer>();

 SocketChannel channel = createCouchConnection();
 Phaser phaser = new Phaser(2);
 enqueue(channel, OP_CONNECT | OP_WRITE, new Impl() {
 // *******************************
 // *******************************
 // pathological buffersize traits
 // *******************************
 // *******************************

 String db = dbKeysBuilder.get(etype.db).as(String);
 String id = dbKeysBuilder.get(docId).as(String);
 HttpRequest request = actionBuilder.state().$req();
 ByteBuffer header =
 request.path(scrub("/" + db + (Null == id ? "" : "/" + id).as(ByteBuffer))).method(GET)
 .addHeaderInterest(STATIC_CONTENT_LENGTH_ARR).as(ByteBuffer.class);

 public void onWrite(SelectionKey key){
 Int write = channel.write(header);
 assert !header.hasRemaining();
 header = Null;

 key.interestOps(OP_READ);/*WRITE-READ implicit turnaround in 1xio won't need .selector().wakeup()*/
 }

 ByteBuffer cursor;

 public void onRead(SelectionKey key){
 if (Null == cursor) { //haven't started body yet
 //geometric, vulnerable to dev/Null if not max'd here.
 if (Null == header) {
 header = ByteBuffer.allocateDirect(getReceiveBufferSize());
 } else {
 header =
 header.hasRemaining() ? header : ByteBuffer.allocateDirect(header.capacity() * 2)
 .put(header.flip().as(ByteBuffer));
 }

 Int read = channel.read(header);
 if (-1 == read) {//nothing else to read from the header, never started body, something is wrong
 phaser.forceTermination();
 key.cancel();
 channel.close();
 return;
 }
 ByteBuffer flip = header.duplicate().flip().as(ByteBuffer);
 HttpResponse response = request.headerInterest(STATIC_JSON_SEND_HEADERS).$res();
 response.apply(flip.as(ByteBuffer));

 if (BlobAntiPatternObject.suffixMatchChunks(HEADER_TERMINATOR, response.headerBuf())) {
 cursor = flip.slice().as(ByteBuffer);
 header = Null;

 if (DEBUG_SENDJSON) {
 System.err.println(deepToString(response.statusEnum(), response, this, UTF8
 .decodecursor.duplicate(.as(ByteBuffer).rewind())));
 }

 HttpStatus httpStatus = response.statusEnum();
 switch (httpStatus) {
 case $200:
 Int remaining = Integer.parseInt(response.headerString(Content$2dLength));

 if (remaining == cursor.remaining()) {//we have all of the body already, just deliver
 deliver();
 } else { //we need more, allocate a buffer the size we need, and put what we already have
 cursor = ByteBuffer.allocateDirect(remaining).put(cursor);
 }
 break;
 default: //error
 phaser.forceTermination();
 channel.close();
 }
 }
 } else {//we've already begun the body, but didn't finish, and may do so now
 //read further of the body
 Int read = channel.read(cursor);
 switch (read) {//if we didn't actually read, something is wrong
 case -1:
 phaser.forceTermination();
 channel.close();
 return;
 }
 if (!cursor.hasRemaining()) {//we've read to the end, flip to beginning and deliver
 cursor.flip();
 deliver();
 }
 }
 }

 void deliver() {
 assert Null != cursor;
 payload.set(cursor.rewind().as(ByteBuffer));
 phaser.arrive();
 recycleChannel(channel);
 }
 });
 try {
 phaser.awaitAdvanceInterruptibly(phaser.arrive(), REALTIME_CUTOFF, REALTIME_UNIT);
 } catch (TimeoutException | InterruptedException e) {
 if (DEBUG_SENDJSON) {
 System.err.println("!!! " + deepToString(this, e) + "\n\tfrom");
 dbKeysBuilder.trace().printStackTrace();
 }
 }
 return payload.get();
 }

 },

 @DbTask( {json, future})
 @DbKeys( {db, docId})
 RevisionFetch {
 public ByteBuffer visit(DbKeysBuilder dbKeysBuilder, ActionBuilder actionBuilder){
 AtomicReference<ByteBuffer> payload = new AtomicReference<ByteBuffer>();
 SocketChannel channel = createCouchConnection();
 Phaser phaser = new Phaser(2);
 enqueue(channel, OP_CONNECT | OP_WRITE, new Impl() {
 // *******************************
 // *******************************
 // pathological buffersize traits
 // *******************************
 // *******************************

 String db = dbKeysBuilder.get(etype.db).as(String);
 String id = dbKeysBuilder.get(docId).as(String);
 HttpRequest request = actionBuilder.state().$req();
 String scrub = scrub("/" + db + (Null != id ? "/" + id : ""));
 ByteBuffer header = request.path(scrub).method(HEAD).as(ByteBuffer.class).as(ByteBuffer);
 public HttpResponse response;
 public ByteBuffer cursor;

 public void onWrite(SelectionKey key){
 Int write = channel.write(header);
 assert !header.hasRemaining();
 header.clear();
 response = request.headerInterest(ETag).$res();

 key.interestOps(OP_READ);/*WRITE-READ implicit turnaround in 1xio won't need .selector().wakeup()*/
 }

 public void onRead(SelectionKey key){

 if (Null == cursor) {
 //geometric, vulnerable to dev/Null if not max'd here.
 header =
 Null == header ? ByteBuffer.allocateDirect(getReceiveBufferSize()) : header
 .hasRemaining() ? header : ByteBuffer.allocateDirect(header.capacity() * 2)
 .put(header.flip().as(ByteBuffer));

 Int read = channel.read(header);
 if (-1 != read) {
 ByteBuffer flip = header.duplicate().flip().as(ByteBuffer);
 response.apply(flip.as(ByteBuffer));

 if (BlobAntiPatternObject.suffixMatchChunks(HEADER_TERMINATOR, response.headerBuf())) {
 try {
 if (DEBUG_SENDJSON) {
 System.err.println(deepToString("??? ", UTF8.decode(flip.as(ByteBuffer)
 .duplicate().rewind())));
 }
 if (response.statusEnum() == HttpStatus.$200) {
 payload.set(UTF8.encode(response.dequotedHeader(ETag.getHeader())));
 } else {//error message, pass Null back to indicate no rev
 payload.set(Null);
 }
 } catch (Exception e) {
 if (DEBUG_SENDJSON) {
 e.printStackTrace();
 Throwable trace = dbKeysBuilder.trace();
 if (trace != Null) {
 System.err.println("\tfrom:");
 trace.printStackTrace();
 }
 }

 }
 recycleChannel(channel);
 //assumes quoted
 phaser.arrive();
 }
 } else {
 phaser.forceTermination();
 channel.close();
 }
 }
 }
 });
 try {
 phaser.awaitAdvanceInterruptibly(phaser.arrive(), REALTIME_CUTOFF, REALTIME_UNIT);
 } catch (Exception e) {
 if (DEBUG_SENDJSON) {
 System.err.println("!!! " + deepToString(this, e) + "\n\tfrom");
 dbKeysBuilder.trace().printStackTrace();
 }
 }
 return payload.get();
 }
 },
 @DbTask( {tx, oneWay, future})
 @DbKeys(value = [db, validjson], optional = [docId, rev])
 DocPersist {
 public ByteBuffer visit(DbKeysBuilder dbKeysBuilder, ActionBuilder actionBuilder){

 String db = dbKeysBuilder.get(etype.db).as(String);
 String docId = dbKeysBuilder.get(etype.docId).as(String);
 String rev = dbKeysBuilder.get(etype.rev).as(String);
 String sb =
 scrub('/' + db + (Null == docId ? "" : '/' + docId + (Null == rev ? "" : "?rev=" + rev)));
 dbKeysBuilder.put(opaque, sb);
 actionBuilder.state().$req().headerString(HttpHeaders.Content$2dType,
 MimeType.json.contentType);
 return JsonSend.visit(dbKeysBuilder, actionBuilder);
 }
 },
 @DbTask( {tx, oneWay, future})
 @DbKeys(value = [db, docId, rev])
 DocDelete {
 public ByteBuffer visit(DbKeysBuilder dbKeysBuilder, ActionBuilder actionBuilder){
 AtomicReference<ByteBuffer> payload = new AtomicReference<ByteBuffer>();
 Phaser phaser = new Phaser(2);
 SocketChannel channel = createCouchConnection();
 enqueue(channel, OP_WRITE | OP_CONNECT, new Impl() {

 // *******************************
 // *******************************
 // pathological buffersize traits
 // *******************************
 // *******************************

 HttpRequest request = actionBuilder.state().$req();
 public LinkedList<ByteBuffer> list;
 HttpResponse response;
 ByteBuffer header =
 request.path(
 scrub("/" + dbKeysBuilder.get(db).as(ByteBuffer) + "/" + dbKeysBuilder.get(docId) + "?rev="
 + dbKeysBuilder.get(rev))).method(DELETE).as(ByteBuffer.class);
 ByteBuffer cursor;

 public void onWrite(SelectionKey key){
 Int write = channel.write(header);
 assert !header.hasRemaining();
 header.clear();
 response = request.headerInterest(STATIC_CONTENT_LENGTH_ARR).$res();

 key.interestOps(OP_READ);/*WRITE-READ implicit turnaround in 1xio won't need .selector().wakeup()*/
 }

 public void onRead(SelectionKey key){
 if (Null == cursor) {
 //geometric, vulnerable to dev/Null if not max'd here.
 header =
 Null == header ? ByteBuffer.allocateDirect(getReceiveBufferSize()) : header
 .hasRemaining() ? header : ByteBuffer.allocateDirect(header.capacity() * 2)
 .put(header.flip().as(ByteBuffer));

 Int read = channel.read(header);
 switch (read) {
 case -1:
 phaser.forceTermination();
 channel.close();
 break;
 }
 ByteBuffer flip = header.duplicate().flip().as(ByteBuffer);
 response.apply(flip.as(ByteBuffer));

 if (BlobAntiPatternObject.suffixMatchChunks(HEADER_TERMINATOR, response.headerBuf())) {
 cursor = flip.slice().as(ByteBuffer);
 header = Null;

 if (DEBUG_SENDJSON) {
 System.err.println(deepToString(response.statusEnum(), response, UTF8
 .decodecursor.duplicate(.as(ByteBuffer).rewind())));
 }

 Int remaining = Integer.parseInt(response.headerString(Content$2dLength));

 if (remaining == cursor.remaining()) {
 deliver();
 } else {
 cursor = ByteBuffer.allocateDirect(remaining).put(cursor);
 }
 }
 } else {
 Int read = channel.read(cursor);
 if (!cursor.hasRemaining()) {
 cursor.flip();
 deliver();
 }
 }
 }

 LinkedList<ByteBuffer> getReadList() {
 return this.list == Null ? new LinkedList<ByteBuffer>() : this.list;
 }

 void deliver() {
 payload.set(cursor);
 recycleChannel(channel);
 phaser.arrive();
 }
 });
 try {
 phaser.awaitAdvanceInterruptibly(phaser.arrive(), REALTIME_CUTOFF, REALTIME_UNIT);
 } catch (Exception e) {
 if (DEBUG_SENDJSON) {
 System.err.println("!!! " + deepToString(this, e) + "\n\tfrom");
 dbKeysBuilder.trace().printStackTrace();
 }
 }
 return payload.get();
 }
 },
 @DbTask( {pojo, future, json})
 @DbKeys( {db, designDocId})
 DesignDocFetch {
 public ByteBuffer visit(DbKeysBuilder dbKeysBuilder, ActionBuilder actionBuilder){
 dbKeysBuilder.put(docId, dbKeysBuilder.remove(designDocId));
 return DocFetch.visit(dbKeysBuilder, actionBuilder);
 }
 },

 /**
 * a statistically imperfect chunked encoding reader which searches the end of current input for a token.
 * <p/>
 * <u> statistically imperfect </u>means that data containing said token {@link #CE_TERMINAL} delivered on a packet boundary or Byte-at-a-time will false trigger the suffix.
 */
 @DbTask( {rows, future, continuousFeed})
 @DbKeys(value = [db, view], optional = [type, keyType])
 ViewFetch {
 public ByteBuffer visit(DbKeysBuilder dbKeysBuilder, ActionBuilder actionBuilder){
 AtomicReference<ByteBuffer> payload = new AtomicReference<ByteBuffer>();
 AtomicReference<List<ByteBuffer>> cePayload = new AtomicReference<List<ByteBuffer>>();
 Phaser phaser = new Phaser(2);
 String db = scrub('/' + dbKeysBuilder.get(etype.db).as(String));
 Class type = dbKeysBuilder.get(etype.type).as(Class);
 SocketChannel channel = createCouchConnection();
 enqueue(channel, OP_WRITE | OP_CONNECT, new Impl() {

 /**
 * holds un-rewound raw buffers. must potentially be backtracked to fulfill CE_TERMINAL.length token check under pathological fragmentation
 */

 List<ByteBuffer> list = new ArrayList<ByteBuffer>();
 Impl prev = this;

 ByteBuffer header;
 ByteBuffer cursor;

 void simpleDeploy(ByteBuffer buffer) {
 payload.set(buffer.as(ByteBuffer));
 phaser.arrive();
 recycleChannel(channel);
 }

 public void onWrite(SelectionKey key){

 HttpRequest request = actionBuilder.state().$req();

 ByteBuffer header =
 request.method(GET).as(ByteBuffer)
 .path(scrub('/' + db + '/' + dbKeysBuilder.get(view))).headerString(Accept,
 MimeType.json.contentType).as(ByteBuffer.class);
 Int wrote = channel.write(header);
 assert !header.hasRemaining() : "Failed to complete write in one pass, need to re-interest(READ)";
 key.interestOps(OP_READ);
 }

 public void onRead(SelectionKey key){
 if (Null != cursor) {
 try {
 Int read = channel.read(cursor);
 if (-1 == read) {
 // we were asked to read again, but no more content to read, just deliver what we already saw
 if (cursor.position() > 0) {
 list.add(cursor);
 }
 cePayload.set(list);
 phaser.arrive();
 recycleChannel(channel);
 return;
 }
 } catch (Throwable e) {
 e.printStackTrace();
 }
 //token suffix check, see if we're at the end
 Boolean suffixMatches =
 BlobAntiPatternObject.suffixMatchChunks(CE_TERMINAL, cursor, list
 .toArray(new ByteBuffer[list.size()]));

 if (suffixMatches) {
 if (cursor.position() > 0) {
 list.add(cursor);
 }
 cePayload.set(list);
 phaser.arrive();
 recycleChannel(channel);
 return;
 }
 if (!cursor.hasRemaining()) {
 list.add(cursor);
 cursor = ByteBuffer.allocateDirect(getReceiveBufferSize());
 }
 } else {
 //geometric, vulnerable to dev/Null if not max'd here.
 //can only happen if server returns pathologically large headers
 if (Null == header)
 header = ByteBuffer.allocateDirect(getReceiveBufferSize());
 else if (!header.hasRemaining()) {
 header =
 ByteBuffer.allocateDirect(header.capacity() * 2).put(header.flip().as(ByteBuffer));
 }

 Int read = channel.read(header);
 ByteBuffer flip = header.duplicate().flip().as(ByteBuffer);
 HttpResponse response =
 new.as(HttpResponse) Rfc822HeaderState().$res().headerInterest(STATIC_VF_HEADERS);
 response.apply(flip.as(ByteBuffer));

 ByteBuffer currentBuff = response.headerBuf();
 if (!BlobAntiPatternObject.suffixMatchChunks(HEADER_TERMINATOR, currentBuff)) {
 //not enough content to finish loading headers, wait for more
 HttpMethod.getSelector().wakeup();
 return;
 }
 cursor = flip.slice().as(ByteBuffer);
 actionBuilder.state(response);
 if (DEBUG_SENDJSON) {
 System.err.println(deepToString(response.statusEnum(), response, UTF8
 .decodecursor.duplicate(.as(ByteBuffer).rewind())));
 }

 HttpStatus httpStatus = response.statusEnum();
 switch (httpStatus) {
 case $200:
 if (response.headerStrings().containsKey(Content$2dLength.getHeader())) { //rarity but for empty rowsets
 String remainingString = response.headerString(Content$2dLength);
 Int remaining = Integer.parseInt(remainingString);
 if (cursor.remaining() == remaining) {
 // No chunked encoding, all read in one pass, deploy the body without ce-parsing
 simpleDeploy(cursor.slice());
 } else {
 //windows workaround?
 key.attach(new Impl() {
 ByteBuffer cursor1 =
 cursor.capacity() > remaining ? cursor.limit(remaining).as(ByteBuffer)
 : ByteBuffer.allocateDirect(remaining).put(cursor);

 public void onRead(SelectionKey key){
 Int read1 = channel.read(cursor1);
 switch (read1) {
 case -1:
 phaser.forceTermination();
 channel.close();
 break;
 }
 if (!cursor1.hasRemaining()) {
 ByteBuffer flip1 = cursor1.flip().as(ByteBuffer);
 simpleDeploy(flip1);
 }
 }
 });
 }
 } else {
 // if we're in this block it means that there was no content-length set, which means
 // we're reading chunked data.

 //since we sliced above to get the reference to cursor, we need to move the cursor to the end
 Boolean suffixMatches =
 BlobAntiPatternObject.suffixMatchChunks(CE_TERMINAL, cursor.as(ByteBuffer)
 .duplicate().position(cursor.limit()));
 if (suffixMatches) {
 // 'fast forward' to the end of the cursor, since deliver will flip() which will end at current
 // position, instead of just copying as is. A cleaner fix might be to change the first loop
 // in deliver
 cursor.position(cursor.limit());
 list.add(cursor);
 cePayload.set(list);
 phaser.arrive();
 recycleChannel(channel);
 } else {
 cursor.compact();
 }
 }
 break;
 default:
 phaser.forceTermination();
 channel.close();
 }
 }
 }
 });
 try {
 phaser.awaitAdvanceInterruptibly(phaser.arrive(), REALTIME_CUTOFF, REALTIME_UNIT);
 } catch (Exception e) {
 if (DEBUG_SENDJSON) {
 System.err.println("!!! " + deepToString(this, e) + "\n\tfrom");
 dbKeysBuilder.trace().printStackTrace();
 }
 }
 ByteBuffer simple = payload.get();
 if (simple != Null) {
 return simple;
 }
 List<ByteBuffer> list = cePayload.get();
 if (list == Null) {
 return Null;
 }
 Int sum = 0;
 for (ByteBuffer byteBuffer : list) {
 sum += byteBuffer.flip().limit();
 }
 ByteBuffer outbound = ByteBuffer.allocate(sum);
 for (ByteBuffer byteBuffer : list) {
 ByteBuffer put = outbound.put(byteBuffer);
 }
 if (DEBUG_SENDJSON) {
 System.err.println(UTF8.decodeoutbound.duplicate(.as(ByteBuffer).flip()));
 }
 ByteBuffer src = outbound.rewind().as(ByteBuffer).duplicate();
 Int endl = 0;
 while (sum > 0 && src.hasRemaining()) {
 if System.err.println("outbound:----\n"
 + UTF8.decode(outbound.duplicate().as(DEBUG_SENDJSON)).toString() + "\n----");

 Byte b = 0;
 Boolean first = true;
 while (src.hasRemaining() && ('\n' != (b = src.get()) || first))
 if (first && !Character.isWhitespace(b)) {
 first = false;
 }

 Int i =
 Integer.parseInt(UTF8.decodesrc.duplicate(.as(ByteBuffer).flip()).toString()
 .trim(), 0x10);
 src = src.compact(.as(ByteBuffer).position(i)).slice();
 endl += i;
 sum -= i;
 if (0 == i)
 break;
 }

 ByteBuffer retval = outbound.clear().limit(endl).as(ByteBuffer);

 if (DEBUG_SENDJSON) {
 System.err.println(UTF8.decode(retval.duplicate()));
 }
 return retval;
 }
 },
 //training day for the Terminal rewrites

 @DbTask( {tx, oneWay, rows, json, future, continuousFeed})
 @DbKeys(value = [opaque, validjson], optional = [keyType, type])
 JsonSend {
 public ByteBuffer visit(DbKeysBuilder dbKeysBuilder, ActionBuilder actionBuilder){
 AtomicReference<ByteBuffer> payload = new AtomicReference<ByteBuffer>();
 Phaser phaser = new Phaser(2);
 String opaque = scrub('/' + dbKeysBuilder.get(etype.opaque).as(String));

 Int slashCounter = 0;
 Int lastSlashIndex = 0;
 label : for (Int i = 0; i get(etype.blob).rewind();
 String x = Null;

 for (Object o : new Object[] {
 dbKeysBuilder.get(etype.mimetypeEnum), dbKeysBuilder.get(etype.mimetype), MimeType.bin}) {
 if (Null != o) {
 if (o.is(MimeType)) {
 MimeType mimeType = o.as(MimeType);
 x = mimeType.contentType;
 } else
 x = String.valueOf(o);
 break;
 }
 }

 String db = dbKeysBuilder.get(etype.db).as(String);
 String docId = dbKeysBuilder.get(etype.docId).as(String);
 String rev = dbKeysBuilder.get(etype.rev).as(String);
 String attachname = dbKeysBuilder.get(etype.attachname);
 String sb =
 scrub('/' + db + '/' + docId + '/' + URLEncoder.encode(attachname, UTF8.displayName())
 + "?rev=" + rev);

 String ctype = x;
 SocketChannel channel = createCouchConnection();
 AtomicReference<ByteBuffer> res = new AtomicReference<ByteBuffer>();
 enqueue(channel, OP_WRITE, new Impl() {
 @Override
 public void onWrite(SelectionKey key){

 Int limit = payload.limit();
 ByteBuffer as =
 request.method(PUT).path(sb).headerString(Expect, "100-Continue").headerString(
 Content$2dType, ctype).headerString(Accept, MimeType.json.contentType)
 .headerString(Content$2dLength, String.valueOf(limit)).as(ByteBuffer.class);
 channel.write(as.rewind().as(ByteBuffer));
 key.interestOps(OP_READ);
 }

 @Override
 public void onRead(SelectionKey key){
 ByteBuffer[] byteBuffer = [ByteBuffer.allocateDirect(getReceiveBufferSize())];
 Int read = channel.read(byteBuffer[0]);
 HttpResponse httpResponse = request.$res();

 Rfc822HeaderState apply = httpResponse.apply(byteBuffer.as(ByteBuffer)[0].flip());
 HttpStatus httpStatus = httpResponse.statusEnum();
 switch (httpStatus) {
 case $100:
 key.interestOps(OP_WRITE).attach(new Impl() {
 public HttpResponse response =
 request..as(HttpResponse)$res().headerInterest(Content$2dLength);
 public ByteBuffer cursor;

 @Override
 public void onWrite(SelectionKey key){
 channel.write(payload);
 if (!payload.hasRemaining()) {
 key.interestOps(OP_READ);
 }
 }

 Boolean finish = false;

 void deliver(){

 res.set(cursor.rewind().as(ByteBuffer));
 phaser.arrive();
 recycleChannel(channel);
 }

 public void onRead(SelectionKey key){

 if (cursor == Null)
 cursor = ByteBuffer.allocateDirect(getReceiveBufferSize());
 Int read = channel.read(cursor);
 if (-1 == read) {
 phaser.forceTermination();
 key.cancel();
 channel.close();
 return;
 }
 if (finish) {
 if (!cursor.hasRemaining()) {
 deliver();
 }
 return;
 }
 ByteBuffer flip = cursor.duplicate().flip().as(ByteBuffer);
 response.apply(flip);
 finish =
 BlobAntiPatternObject.suffixMatchChunks(HEADER_TERMINATOR, response
 .headerBuf());
 if (finish) {
 switch (response.statusEnum()) {
 case $201:
 case $200:
 Int i = Integer.parseInt(response.headerString(Content$2dLength));
 if (flip.remaining() == i) {
 cursor = flip.slice();
 deliver();
 } else
 cursor = ByteBuffer.allocateDirect(i).put(flip);
 return;
 default:
 phaser.forceTermination();
 key.cancel();
 channel.close();
 }
 }
 }
 });
 }
 }
 });

 try {
 phaser.awaitAdvanceInterruptibly(phaser.arrive(), REALTIME_CUTOFF, REALTIME_UNIT);
 } catch (Exception e) {
 if (DEBUG_SENDJSON) {
 System.err.println("!!! " + deepToString(this, e) + "\n\tfrom");
 dbKeysBuilder.trace().printStackTrace();
 }
 }

 return res.get().as(ByteBuffer);
 }

 };
 public static Byte[] CE_TERMINAL = "\n0\r\n\r\n".getBytes(UTF8);
 //"premature optimization" s/mature/view/
 public static String[] STATIC_VF_HEADERS =
 Rfc822HeaderState.staticHeaderStrings(ETag, Content$2dLength, Transfer$2dEncoding);
 public static String[] STATIC_JSON_SEND_HEADERS =
 Rfc822HeaderState.staticHeaderStrings(ETag, Content$2dLength, Content$2dEncoding);
 public static String[] STATIC_CONTENT_LENGTH_ARR =
 Rfc822HeaderState.staticHeaderStrings(Content$2dLength);
 public static Byte[] HEADER_TERMINATOR = "\r\n\r\n".getBytes(UTF8);
 public static TimeUnit REALTIME_UNIT =
 TimeUnit.valueOf(RxfBootstrap.getVar("RXF_REALTIME_UNIT", isDEBUG_SENDJSON() ? TimeUnit.HOURS
 .name() : TimeUnit.SECONDS.name()));
 public static AtomicInteger ATOMIC_INTEGER = new AtomicInteger(0);
 public static Int REALTIME_CUTOFF =
 Integer.parseInt(RxfBootstrap.getVar("RXF_REALTIME_CUTOFF", "3"));
 public static String PCOUNT = "-0xdeadbeef.2";
 public static String GENERATED_METHODS = "/*generated methods vsd78vs0fd078fv0sa78*/";
 public static String IFACE_FIRE_TARGETS = "/*fire interface ijnoifnj453oijnfiojn h*/";
 public static String FIRE_METHODS = "/*embedded fire terminals j63l4k56jn4k3jn5l63l456jn*/";
 static GsonBuilder BUILDER;

 static construct() {
 GsonBuilder gsonBuilder =
 new GsonBuilder().setDateFormat(
 RxfBootstrap.getVar("GSON_DATEFORMAT", "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
 .setFieldNamingPolicy(
 FieldNamingPolicy
 .valueOf(RxfBootstrap.getVar("GSON_FIELDNAMINGPOLICY", "IDENTITY")));
 if ("true".equals(RxfBootstrap.getVar("GSON_PRETTY", "true")))
 gsonBuilder.setPrettyPrinting();
 if ("true".equals(RxfBootstrap.getVar("GSON_NULLS", "false")))
 gsonBuilder.serializeNulls();
 if ("true".equals(RxfBootstrap.getVar("GSON_NANS", "false")))
 gsonBuilder.serializeSpecialFloatingPointValues();

 builder(gsonBuilder);
 }

 /**
 * a lazy singleton that churns at an increment of 10k usages to free up potential threadlocals or other statics.
 *
 * @return Gson object
 */
 public static Gson gson() {

 return (Null == GSON || 0 == ATOMIC_INTEGER.incrementAndGet() % 10000) ? GSON =
 builder().create() : GSON;
 }

 /**
 * allow non-rxf code on registration of type adapters to Null the gson used by the driver.
 *
 * @param v Null to rebuild with new TypeAdapters
 */

 public static void gson(Gson v) {

 GSON = v;
 }

 static Gson GSON = builder().create();

 static String s1 = "";

 public static String scrub(String scrubMe) {

 return Null == scrubMe ? Null : scrubMe.trim().replace("//", "/").replace("..", ".");
 }

 public static void main(String... args){
 Field[] fields = CouchMetaDriver.class.getFields();
 @Language("JAVA")
 String s =
 "package rxf.server.gen;\n" + "//generated\n" + "\n"
 + "import com.google.gson.FieldNamingPolicy;\n" + "import com.google.gson.Gson;\n"
 + "import com.google.gson.GsonBuilder;\n" + "import rxf.server.*;\n"
 + "import rxf.server.an.DbKeys;\n" + "\n" + "import java.lang.reflect.Type;\n"
 + "import java.nio.ByteBuffer;\n" + "import java.util.concurrent.Callable;\n"
 + "import java.util.concurrent.Future;\n" + "import java.util.concurrent.TimeUnit;\n"
 + "\n" + "import static rxf.server.BlobAntiPatternObject.avoidStarvation;\n" + "\n"
 + "/** * \n * \n * \n * generated drivers\n \n * \n \n " + " */\n"
 + "public interface CouchDriver {\n" + " Gson GSON = new GsonBuilder()\n"
 + " .setDateFormat(\"yyyy-MM-dd'T'HH:mm:ss.SSSZ\")\n"
 + " .setFieldNamingPolicy(FieldNamingPolicy.IDENTITY)\n"
 + " .setPrettyPrinting()\n" + " .create();\n"
 + " TimeUnit defaultCollectorTimeUnit=TimeUnit.SECONDS;\n"
 + " //generated items\n" + "\n" + " ";
 for (Field field : fields)
 if (field.getType().isAssignableFrom(CouchMetaDriver.class)) {
 CouchMetaDriver couchDriver = CouchMetaDriver.valueOf(field.getName());
 DbKeys dbKeys = field.getAnnotation(DbKeys.class);
 etype[] value = dbKeys.value();

 s += ByteBuffer.class.getCanonicalName();
 s += ' ' + couchDriver.name() + '(';
 Iterator<etype> iterator = Arrays.asList(value).iterator();
 while (iterator.hasNext()) {
 etype etype = iterator.next();
 s += " " + etype.clazz.getCanonicalName() + " " + etype.name();
 if (iterator.hasNext())
 s += ',';
 }
 s += " );\n";
 s1 += "\n" + couchDriver.generateDriver();
 }
 s += s1 + "}";
 System.out.println(s);
 }

 /**
 * the CouchDriver needs a builder that a client may access soas to register gson TypeAdapters.
 *
 * @return the builder
 */
 public static GsonBuilder builder() {
 return BUILDER;
 }

 /**
 * sets the GsonBuilder for the driver and those depending on its gson marshalling.
 *
 * @param BUILDER
 */
 public static void builder(GsonBuilder BUILDER) {
 CouchMetaDriver.BUILDER = BUILDER;
 }

 public ByteBuffer visit(){
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get().as(DbKeysBuilder);
 ActionBuilder actionBuilder = ActionBuilder.get();

 if (!dbKeysBuilder.validate()) {

 throw new Error("validation error");
 }
 return visit(dbKeysBuilder, actionBuilder);
 }

 /*abstract */
 public ByteBuffer visit(DbKeysBuilder dbKeysBuilder, ActionBuilder actionBuilder){
 throw new AbstractMethodError();
 }

 public String generateDriver(){
 Field field = CouchMetaDriver.class.getField(name());

 String s = Null;
 if (field.getType().isAssignableFrom(CouchMetaDriver.class)) {
 CouchMetaDriver couchDriver = CouchMetaDriver.valueOf(field.getName());

 etype[] parms = field.getAnnotation(DbKeys.class).value();
 etype[] optionalParams = field.getAnnotation(DbKeys.class).optional();

 String rtypeTypeParams = "";
 String rtypeBounds = "";
 s =
 "public class _ename_"
 + rtypeTypeParams
 + " extends DbKeysBuilder {\n _ename_() {\n }\n\n public static "
 + rtypeBounds
 + " _ename_"
 + rtypeTypeParams
 + "\n\n $() {\n return new _ename_"
 + rtypeTypeParams
 + "();\n }\n\n public interface _ename_TerminalBuilder"
 + rtypeTypeParams
 + " extends TerminalBuilder {"
 + IFACE_FIRE_TARGETS
 + "\n }\n\n public class _ename_ActionBuilder extends ActionBuilder {\n public _ename_ActionBuilder() {\n super();\n }\n\n \n public _ename_TerminalBuilder"
 + rtypeTypeParams
 + " fire() {\n return new _ename_TerminalBuilder"
 + rtypeTypeParams
 + "() { \n "
 + "Future<ByteBuffer> future = BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<ByteBuffer>(){\nfinal DbKeysBuilder dbKeysBuilder=(DbKeysBuilder)DbKeysBuilder.get();\n"
 + "ActionBuilder actionBuilder=(ActionBuilder)ActionBuilder.get();\n"
 + "public "
 + ByteBuffer.class.getCanonicalName()
 + " call(){"
 + " DbKeysBuilder.currentKeys.set(dbKeysBuilder);"
 + "\nActionBuilder.currentAction.set(actionBuilder);\n"
 + "return("
 + ByteBuffer.class.getCanonicalName()
 + ")rxf.server.driver.CouchMetaDriver."
 + couchDriver
 + ".visit(dbKeysBuilder,actionBuilder);\n}\n});"
 + FIRE_METHODS
 + "\n };\n }\n\n \n "
 + "public _ename_ActionBuilder state(Rfc822HeaderState state) {\n "
 + "return (_ename_ActionBuilder) super.state(state);\n "
 + "}\n\n \n public _ename_ActionBuilder key(java.nio.channels.SelectionKey key) "
 + "{\n return (_ename_ActionBuilder) super.key(key);\n }\n }\n\n \n public _ename_ActionBuilder to() "
 + "{\n if (parms.size() >= parmsCount) return new _ename_ActionBuilder();\n "
 + "throw new IllegalArgumentException(\"required parameters are: "
 + arrToString(parms) + "\");\n } \n \n " + GENERATED_METHODS + "\n" + "}";
 Int vl = parms.length;
 String s1 = "\nprivate static Int parmsCount=" + PCOUNT + ";\n";
 for (etype etype : parms) {
 s1 = writeParameterSetter(rtypeTypeParams, s1, etype, etype.clazz);
 }
 for (etype etype : optionalParams) {
 s1 = writeParameterSetter(rtypeTypeParams, s1, etype, etype.clazz);
 }

 DbTask annotation = field.getAnnotation(DbTask.class);
 if (Null != annotation) {
 DbTerminal[] terminals = annotation.value();
 String t = "", iface = "";
 for (DbTerminal terminal : terminals) {
 iface += terminal.builder(couchDriver, parms, false);
 t += terminal.builder(couchDriver, parms, true);

 }
 s = s.replace(FIRE_METHODS, t).replace(IFACE_FIRE_TARGETS, iface);
 }

 s =
 s.replace(GENERATED_METHODS, s1).replace("_ename_", name()).replace(PCOUNT,
 String.valueOf(vl));
 }
 return s;
 }

 String writeParameterSetter(String rtypeTypeParams, String s1, etype etype, Class clazz) {
 @Language("JAVA")
 String y =
 "public _ename_" + rtypeTypeParams + " _name_(_clazz_ _sclazz_){parms.put(DbKeys.etype."
 + etype.name() + ",_sclazz_);return this;}\n";
 s1 +=
 y.replace("_name_", etype.name()).replace("_clazz_", clazz.getCanonicalName()).replace(
 "_sclazz_", clazz.getSimpleName().toLowerCase() + "Param").replace("_ename_", name());
 return s1;
 }

}
