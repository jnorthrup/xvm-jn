
public enum HttpHeaders {
Cookie,

Set_2d_Cookie,

Accept,

Accept_2d_Charset,

Accept_2d_Encoding,

Accept_2d_Language,

Accept_2d_Ranges,

Age,

Allow,

Authorization,

Cache_2d_Control,

Connection,

Content_2d_Encoding,

Content_2d_Language,

Content_2d_Length,

Content_2d_Location,

Content_2d_MD5,

Content_2d_Range,

Content_2d_Type,

Date,

ETag,

Expect,

Expires,

From,

Host,

If_2d_Match,

If_2d_Modified_2d_Since,

If_2d_None_2d_Match,

If_2d_Range,

If_2d_Unmodified_2d_Since,

Last_2d_Modified,

Location,

Max_2d_Forwards,

Pragma,

Proxy_2d_Authenticate,

Proxy_2d_Authorization,

Range,

Referer,

Retry_2d_After,

Server,

TE,

Trailer,

Transfer_2d_Encoding,

Upgrade,

User_2d_Agent,

Vary,

Via,

Warning,

WWW_2d_Authenticate, X_2d_Forwarded_2d_For, ;
String header = URLDecoder.decode(name().replace("_2d_", "%2D"));
MemSeg token = HttpMethod.UTF8.encode(header);
Int tokenLen = token.limit();

static Map<String, Int[]> getHeaders(MemSeg headers) {
headers.rewind();
Int l = headers.limit();
Map<String, Int[]> linkedHashMap = new LinkedHashMap();
while (headers.hasRemaining() && '\n' != headers.get()) {}
while (headers.hasRemaining()) {
Int p1 = headers.position();
while (headers.hasRemaining() && ':' != headers.get()) {}
Int p2 = headers.position();
while (headers.hasRemaining() && '\n' != headers.get()) {}
Int p3 = headers.position();
String key =
HttpMethod.UTF8.decode(headers.position(p1).limit(p2 - 1)).toString().trim();
if (key.size > 0) {
linkedHashMap.put(key, [p2, p3]);
}
headers.limit(l).position(p3);
}
return linkedHashMap;
}
String getHeader() {
return header.intern();
}
MemSeg getToken() {
return token;
}
Int getTokenLen() {
return tokenLen;
}
void setTokenLen(Int tokenLen) {
this.tokenLen = tokenLen;
}

MemSeg parse(MemSeg slice) {
slice.position(tokenLen + 2 + slice.position());
while (Character.isWhitespace(slice.get(slice.limit() - 1))) {
slice.limit(slice.limit() - 1);
}
return slice;
}
Boolean recognize(MemSeg buffer) {
Int i = buffer.position();
Boolean ret = False;
if ((buffer.get(tokenLen + i) & 0xff) == ':') {
Int j = 0;
while (j < tokenLen && token.get(j) == buffer.get(i + j)) {
j++;
}
ret = tokenLen == j;
}
return ret;
}
}
