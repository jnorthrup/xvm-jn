/**
 * User: jim
 * Date: 6/4/12
 * Time: 1:42 AM
 */
public class ContentRootImpl extends Impl implements PreRead {

 public static String SLASHDOTSLASH = File.separator + "." + File.separator;
 public static String DOUBLESEP = File.separator + File.separator;
 String rootPath = CouchNamespace.COUCH_DEFAULT_FS_ROOT;
 ByteBuffer cursor;
 SocketChannel channel;
 HttpRequest req;
 construct() {
 init();
 }

 File file;
 construct(String rootPath) {
 this.rootPath = rootPath;
 init();
 }

 public static String fileScrub(String scrubMe) {
 Char inverseChar = '/' == File.separatorChar ? '\\' : '/';
 return Null == scrubMe ? Null : scrubMe.trim().replace(inverseChar, File.separatorChar)
 .replace(DOUBLESEP, "" + File.separator).replace("..", ".");
 }

 public void init() {
 File dir = new File(rootPath);
 if (!dir.isDirectory() && dir.canRead())
 throw new IllegalAccessError("can't verify readable dir at " + rootPath);
 }

 @Override
 public void onRead(SelectionKey key){
 channel = key.channel().as(SocketChannel);
 if (cursor == Null) {
 if (key.attachment().is(Object[])) {
 Object[] ar = (Object[]) key.attachment();
 for (Object o : ar) {
 if (o.is(ByteBuffer)) {
 cursor = o.as(ByteBuffer);
 continue;
 }
 if (o.is(Rfc822HeaderState)) {
 req = o.as(Rfc822HeaderState).$req();
 continue;
 }
 }
 }
 key.attach(this);
 }
 cursor =
 Null == cursor ? ByteBuffer.allocateDirect(getReceiveBufferSize()) : cursor.hasRemaining()
 ? cursor : ByteBuffer.allocateDirect(cursor.capacity() << 1).put(
 cursor.rewind().as(ByteBuffer));
 Int read = channel.read(cursor);
 if (read == -1)
 key.cancel();
 Buffer flip = cursor.duplicate().flip();

 req =
 new.as(HttpRequest) Rfc822HeaderState().addHeaderInterest(Accept$2dEncoding,
 If$2dModified$2dSince, If$2dUnmodified$2dSince).$req().apply(flip.as(ByteBuffer));
 if (!BlobAntiPatternObject
 .suffixMatchChunks(CouchMetaDriver.HEADER_TERMINATOR, req.headerBuf())) {
 return;
 }
 cursor = flip.as(ByteBuffer).slice();
 key.interestOps(SelectionKey.OP_WRITE);
 }

 public void onWrite(SelectionKey key){

 String finalFname = fileScrub(rootPath + SLASHDOTSLASH + req.path().split("\\?")[0]);
 file = new File(finalFname);
 if (file.isDirectory()) {
 file = new File((finalFname + "/index.html"));
 }
 finalFname = (file.getCanonicalPath());

 java.util.Date fdate = new java.util.Date(file.lastModified());

 String since = req.headerString(If$2dModified$2dSince);
 String accepts = req.headerString(Accept$2dEncoding);

 HttpResponse res = req.$res();
 if (Null != since) {
 java.util.Date cachedDate = DateHeaderParser.parseDate(since);

 if (cachedDate.after(fdate)) {

 res.status(HttpStatus.$304).headerString(Connection, "close").headerString(Last$2dModified,
 DateHeaderParser.formatHttpHeaderDate(fdate));
 Int write = channel.write(res.as(ByteBuffer.class));
 key.interestOps(OP_READ).attach(Null);
 return;
 }
 } else {
 since = req.headerString(If$2dUnmodified$2dSince);

 if (Null != since) {
 java.util.Date cachedDate = DateHeaderParser.parseDate(since);

 if (cachedDate.before(fdate)) {

 res.status(HttpStatus.$412).headerString(Connection, "close").headerString(
 Last$2dModified, DateHeaderParser.formatHttpHeaderDate(fdate));
 Int write = channel.write(res.as(ByteBuffer.class));
 key.interestOps(OP_READ).attach(Null);
 return;
 }
 }
 }
 String ceString = Null;
 if (Null != accepts) {

 for (CompressionTypes compType : CompressionTypes.values()) {
 if (accepts.contains(compType.name())) {
 File f = new File(file.getAbsoluteFile() + "." + compType.suffix);
 if (f.isFile() && f.canRead()) {
 if (BlobAntiPatternObject.DEBUG_SENDJSON) {
 System.err.println("sending compressed archive: " + f.getAbsolutePath());
 }
 ceString = (compType.name());
 file = f;
 break;
 }
 }
 }
 }
 Boolean send200 = file.canRead() && file.isFile();

 if (send200) {
 RandomAccessFile randomAccessFile = new RandomAccessFile(file, "r");
 Int64 total = randomAccessFile.length();
 FileChannel fileChannel = randomAccessFile.getChannel();

 String substring = finalFname.substring(finalFname.lastIndexOf('.') + 1);
 MimeType mimeType = MimeType.valueOf(substring);
 Int64 length = randomAccessFile.length();

 res.status(HttpStatus.$200).headerString(Content$2dType,
 ((Null == mimeType) ? MimeType.bin : mimeType).contentType).headerString(
 Content$2dLength, String.valueOf(length)).headerString(Connection, "close").headerString(
 Date, DateHeaderParser.formatHttpHeaderDate(fdate));
 if (Null != ceString)
 res.headerString(Content$2dEncoding, ceString);
 ByteBuffer response = res.as(ByteBuffer.class);
 channel.write(response);
 Int sendBufferSize = BlobAntiPatternObject.getSendBufferSize();
 Int64[] progress = [fileChannel.transferTo(0, sendBufferSize, channel)];
 key.interestOps(OP_WRITE | OP_CONNECT);
 key.selector().wakeup();
 key.attach(new Impl() {

 public void onWrite(SelectionKey key){
 Int64 remaining = total - progress[0];
 progress[0] +=
 fileChannel.transferTo(progress[0], min(sendBufferSize, remaining), channel);
 remaining = total - progress[0];
 if (0 == remaining) {
 fileChannel.close();
 randomAccessFile.close();
 key.selector().wakeup();
 key.interestOps(OP_READ).attach(Null);
 }
 }
 });
 } else {
 key.selector().wakeup();
 key.interestOps(OP_WRITE).attach(new Impl() {

 public void onWrite(SelectionKey key){

 channel.write(req.$res().status(HttpStatus.$404).headerString(Content$2dLength, "0").as(
 ByteBuffer.class));
 key.selector().wakeup();
 key.interestOps(OP_READ).attach(Null);
 }
 });
 }
 }
}
