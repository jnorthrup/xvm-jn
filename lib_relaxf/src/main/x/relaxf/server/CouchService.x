public service CouchService<E> {
E find(String key);
CouchTx persist(E entity);
Attachments attachments(E entity);
static interface Attachments {
    CouchTx addAttachment(String content, String filename, String contentType);
    Writer addAttachment(String fileName, String contentType);
    CouchTx updateAttachment(String content, String fileName, String contentType);
    Writer updateAttachment(String fileName, String contentType);
    String getAttachment(String fileName);
    CouchTx deleteAttachment(String fileName);
}
static class AttachmentsImpl implements Attachments {
    Object entity;
    String rev;
    String id;
    String db;
    construct (String db, Object obj) {
        this.entity = obj;
        JsonObject jsonObj = CouchMetaDriver.gson().toJsonTree(obj).getAsJsonObject();
        rev = jsonObj.get("_rev").getAsString();
        id = jsonObj.get("_id").getAsString();
        this.db = db;
    }

    CouchTx addAttachment(String content, String fileName, String contentType) {
        JsonSendActionBuilder actionBuilder =
        JsonSend.$().opaque(db + "/" + id + "/" + fileName + "?rev=" + rev).validjson(content)
        .to();
        actionBuilder.state().headerString(HttpHeaders.Content_2dType, contentType);
        CouchTx tx = actionBuilder.fire().tx();
        rev = tx.rev();
        return tx;
    }

    Writer addAttachment(String fileName, String contentType) {
        return new StringWriter() {
            void close() {
                JsonSendActionBuilder actionBuilder =
                JsonSend.$().opaque(db + "/" + id + "/" + fileName + "?rev=" + rev).validjson(
                getBuffer().toString()).to();
                actionBuilder.state().headerString(HttpHeaders.Content_2dType, contentType);
                CouchTx tx = actionBuilder.fire().tx();
                if (!tx.ok() ) {
                    throw new IOException(tx.error());
                }
                rev = tx.rev();
            }
        };
    }

    CouchTx updateAttachment(String content, String fileName, String contentType) {
        JsonSendActionBuilder actionBuilder =
        JsonSend.$().opaque(db + "/" + id + "/" + fileName + "?rev=" + rev).validjson(content)
        .to();
        actionBuilder.state().headerString(HttpHeaders.Content_2dType, contentType);
        CouchTx tx = actionBuilder.fire().tx();
        rev = tx.rev();
        return tx;
    }

    Writer updateAttachment(String fileName, String contentType) {
        return new StringWriter() {
            void close() {
                JsonSendActionBuilder actionBuilder =
                JsonSend.$().opaque(db + "/" + id + "/" + fileName + "?rev=" + rev).validjson(
                getBuffer().toString()).to();
                actionBuilder.state().headerString(HttpHeaders.Content_2dType, contentType);
                CouchTx tx = actionBuilder.fire().tx();
                if (!tx.ok() ) {
                    throw new IOException(tx.error());
                }
                rev = tx.rev();
            }
        };
    }

    String getAttachment(String fileName) {
        return DocFetch.$().db(db).docId(id + "/" + fileName).to().fire().json();
    }

    CouchTx deleteAttachment(String fileName) {
        CouchTx tx = DocDelete.$().db(db).docId(id).rev(rev).to().fire().tx();
        rev = tx.rev();
        return tx;
    }
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
@Documented
annotation View {
    String map();

    String reduce() = "";
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.ANNOTATION_TYPE)
annotation CouchRequestParam {

    String value();

    Boolean isJson() = True;
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.PARAMETER)
@CouchRequestParam("key")
@Documented
annotation Key {
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.PARAMETER)
@CouchRequestParam("keys")
@Documented
annotation Keys {
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.PARAMETER, ElementType.METHOD)
@CouchRequestParam("limit")
@Documented
annotation Limit {

    Int value() = -1;
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.PARAMETER, ElementType.METHOD)
@CouchRequestParam("skip")
@Documented
annotation Skip {

    Int value() = -1;
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.PARAMETER)
@CouchRequestParam("startkey")
@Documented
annotation StartKey {
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.PARAMETER)
@CouchRequestParam("endkey")
@Documented
annotation EndKey {
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.PARAMETER)
@CouchRequestParam("startkey_docid")
@Documented
annotation StartKeyDocId {
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.PARAMETER)
@CouchRequestParam("endkey_docid")
@Documented
annotation EndKeyDocId {
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.PARAMETER, ElementType.METHOD)
@CouchRequestParam("descending")
@Documented
annotation Descending {
    Boolean value() = False;
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.PARAMETER, ElementType.METHOD)
@CouchRequestParam("group")
@Documented
annotation Group {
    Boolean value() = False;
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.PARAMETER, ElementType.METHOD)
@CouchRequestParam("group")
@Documented
annotation GroupLevel {
    Int value() = 0;
}
}