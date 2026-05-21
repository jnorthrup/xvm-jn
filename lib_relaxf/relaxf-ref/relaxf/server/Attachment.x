public class Attachment {

 Int64 length;

 @SerializedName("content_type")
 String contentType;

 Boolean stub = true;

 public Int64 getLength() {
 return length;
 }

 public String getContentType() {
 return contentType;
 }

}
