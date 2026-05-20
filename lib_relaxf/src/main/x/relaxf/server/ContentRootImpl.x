public class ContentRootImpl extends AsioVisitorImpl {
static String SLASHDOTSLASH = "/" + "." + "/";
static String DOUBLESEP = "/" + "/";
String rootPath = CouchNamespace.COUCH_DEFAULT_FS_ROOT;
MemSeg cursor;
Int channel;
HttpRequest req;
construct() {
init();
}
File file;
construct (String rootPath) {
this.rootPath = rootPath;
init();
}
static String fileScrub(String scrubMe) {
char inverseChar = '/';
return Null == scrubMe ? Null : scrubMe.trim().replace(inverseChar, "/")
.replace(DOUBLESEP, "/").replace("..", ".");
}
void init() {
    File dir = new File(rootPath);
    if (!dir.isDirectory() && dir.canRead()) {
        throw new IllegalAccessError("can't verify readable dir at " + rootPath);
    }
}
void onRead(Int key) {
channel = key.channel();
if (cursor == Null) {
if (key.attachment().is(Object[])) {
Object[] ar = key.attachment();
for (Object o : ar) {
if (o.is(MemSeg)) {
cursor = o;
continue;
}
if (o.is(Rfc822HeaderState)) {
req = o._req();
continue;
}
}
}
key.attach(this);
cursor = Null == cursor ? MemSeg.allocateDirect(getReceiveBufferSize()) : cursor.hasRemaining()
? cursor : MemSeg.allocateDirect(cursor.capacity() << 1).put(cursor.rewind());
}
Int read = channel.read(cursor);
if (read == -1) {
key.cancel();
return;
}
Buffer flip = cursor.duplicate().flip();
req = new Rfc822HeaderState().addHeaderInterest(Accept_2dEncoding,
If_2dModified_2dSince, If_2dUnmodified_2dSince)._req().apply(flip);
if (!BlobAntiPatternObject.suffixMatchChunks(CouchMetaDriver.HEADER_TERMINATOR, req.headerBuf())) {
return;
}
cursor = flip.slice();
key.interestOps(Int.OP_WRITE);
}
void onWrite(Int key) {
String finalFname = fileScrub(rootPath + SLASHDOTSLASH + req.path().split("\\?")[0]);
file = new File(finalFname);
if (file.isDirectory()) {
file = new File(finalFname + "/index.html");
}
finalFname = file.getCanonicalPath();
java.util.Date fdate = new java.util.Date(file.lastModified());
String since = req.headerString(If_2dModified_2dSince);
String accepts = req.headerString(Accept_2dEncoding);
HttpResponse res = req._res();
if (Null != since) {
java.util.Date cachedDate = DateHeaderParser.parseDate(since);
if (cachedDate.after(fdate)) {
res.status(HttpStatus._304).headerString(Connection, "close").headerString(Last_2dModified,
DateHeaderParser.formatHttpHeaderDate(fdate));
Int write = channel.write(res.as(MemSeg.class));
key.interestOps(OP_READ).attach(Null);
return;
}
} else {
since = req.headerString(If_2dUnmodified_2dSince);
if (Null != since) {
java.util.Date cachedDate = DateHeaderParser.parseDate(since);
if (cachedDate.before(fdate)) {
res.status(HttpStatus._412).headerString(Connection, "close").headerString(
Last_2dModified, DateHeaderParser.formatHttpHeaderDate(fdate));
Int write = channel.write(res.as(MemSeg.class));
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
ceString = compType.name();
file = f;
break;
}
}
}
}
Boolean send200 = file.canRead() && file.isFile();
if (send200) {
RandomAccessFile randomAccessFile = new RandomAccessFile(file, "r");
Int total = randomAccessFile.size;
Int fileChannel = randomAccessFile.getChannel();
String substring = finalFname.substring(finalFname.lastIndexOf('.') + 1);
MimeType mimeType = MimeType.valueOf(substring);
Int length = randomAccessFile.size;
res.status(HttpStatus._200).headerString(Content_2dType,
((Null == mimeType) ? MimeType.bin : mimeType).contentType).headerString(
Content_2dLength, String.valueOf(length)).headerString(Connection, "close").headerString(
Date, DateHeaderParser.formatHttpHeaderDate(fdate));
if (Null != ceString) {
res.headerString(Content_2dEncoding, ceString);
}
MemSeg response = res.as(MemSeg.class);
channel.write(response);
Int sendBufferSize = BlobAntiPatternObject.getSendBufferSize();
Int[] progress = [fileChannel.transferTo(0, sendBufferSize, channel)];
key.interestOps(OP_WRITE | OP_CONNECT);
key.selector().wakeup();
key.attach(new AsioVisitorImpl() {
void onWrite(Int key) {
Int remaining = total - progress[0];
progress[0] += fileChannel.transferTo(progress[0], min(sendBufferSize, remaining), channel);
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
key.interestOps(OP_WRITE).attach(new AsioVisitorImpl() {
void onWrite(Int key) {
channel.write(req._res().status(HttpStatus._404).headerString(Content_2dLength, "0").as(MemSeg.class));
key.selector().wakeup();
key.interestOps(OP_READ).attach(Null);
}
});
}
}
}