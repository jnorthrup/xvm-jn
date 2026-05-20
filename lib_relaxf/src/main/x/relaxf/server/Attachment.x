
public class Attachment {
Int length;
@SerializedName("content_type")
String contentType;
Boolean stub = True;
Int getLength() {
return length;
}
String getContentType() {
return contentType;
}
}
