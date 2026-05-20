

public service CouchDriver {

public class DbCreate extends DbKeysBuilder {
static Int parmsCount = 1;
construct() {
}
static DbCreate
$() {
return new DbCreate();
}
DbCreateActionBuilder to() {
if (parms.size >= parmsCount) {
return new DbCreateActionBuilder();
}
throw new IllegalArgumentException("required parameters are: [db]");
}
DbCreate db(java.lang.String stringParam) {
parms.put(DbKeys.etype.db, stringParam);
return this;
}
public service DbCreateTerminalBuilder extends TerminalBuilder {
CouchTx tx();

void oneWay();
}
public class DbCreateActionBuilder extends ActionBuilder {
construct() {
super();
}
DbCreateTerminalBuilder fire() {
return new DbCreateTerminalBuilder() {
Future<MemSeg> future =
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<MemSeg>() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
java.nio.MemSeg call() {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
return rxf.server.driver.CouchMetaDriver.DbCreate.visit(dbKeysBuilder,
actionBuilder);
}
});
CouchTx tx() {
try {
return CouchMetaDriver.gson().fromJson(
one.xio.HttpMethod.UTF8.decode(future.get()).toString(), CouchTx.class);
} catch (Exception e) {
if (rxf.server.BlobAntiPatternObject.DEBUG_SENDJSON) { e.printStackTrace(); }
}
return Null;
}

void oneWay() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Runnable() {
void run() {
try {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
future.get();
} catch (Exception e) {
e.printStackTrace();
}
}
});
}
};
}
DbCreateActionBuilder state(Rfc822HeaderState state) {
return this;
}
DbCreateActionBuilder key(java.nio.channels.Int key) {
    return super.key(key);
}
}
}
public class DbDelete extends DbKeysBuilder {
static Int parmsCount = 1;
construct() {
}
static DbDelete
$() {
return new DbDelete();
}
DbDeleteActionBuilder to() {
if (parms.size >= parmsCount) { return new DbDeleteActionBuilder(); }
throw new IllegalArgumentException("required parameters are: [db]");
}
DbDelete db(java.lang.String stringParam) {
parms.put(DbKeys.etype.db, stringParam);
return this;
}
public service DbDeleteTerminalBuilder extends TerminalBuilder {
CouchTx tx();

void oneWay();
}
public class DbDeleteActionBuilder extends ActionBuilder {
construct() {
super();
}
DbDeleteTerminalBuilder fire() {
return new DbDeleteTerminalBuilder() {
Future<MemSeg> future =
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<MemSeg>() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
java.nio.MemSeg call() {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
return rxf.server.driver.CouchMetaDriver.DbDelete.visit(dbKeysBuilder,
actionBuilder);
}
});
CouchTx tx() {
try {
return CouchMetaDriver.gson().fromJson(
one.xio.HttpMethod.UTF8.decode(future.get()).toString(), CouchTx.class);
} catch (Exception e) {
if (rxf.server.BlobAntiPatternObject.DEBUG_SENDJSON) { e.printStackTrace(); }
}
return Null;
}

void oneWay() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Runnable() {
void run() {
try {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
future.get();
} catch (Exception e) {
e.printStackTrace();
}
}
});
}
};
}
DbDeleteActionBuilder state(Rfc822HeaderState state) {
return super.state(state);
}
DbDeleteActionBuilder key(java.nio.channels.Int key) {
return super.key(key);
}
}
}
public class DocFetch extends DbKeysBuilder {
static Int parmsCount = 2;
construct() {
}
static DocFetch
$() {
return new DocFetch();
}
DocFetchActionBuilder to() {
if (parms.size >= parmsCount) { return new DocFetchActionBuilder(); }
throw new IllegalArgumentException("required parameters are: [db, docId]");
}
DocFetch db(java.lang.String stringParam) {
parms.put(DbKeys.etype.db, stringParam);
return this;
}
DocFetch docId(java.lang.String stringParam) {
parms.put(DbKeys.etype.docId, stringParam);
return this;
}
public service DocFetchTerminalBuilder extends TerminalBuilder {
java.nio.MemSeg pojo();
Future<MemSeg> future();
String json();
}
public class DocFetchActionBuilder extends ActionBuilder {
construct() {
super();
}
DocFetchTerminalBuilder fire() {
return new DocFetchTerminalBuilder() {
Future<MemSeg> future =
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<MemSeg>() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
java.nio.MemSeg call() {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
return rxf.server.driver.CouchMetaDriver.DocFetch.visit(dbKeysBuilder,
actionBuilder);
}
});
java.nio.MemSeg pojo() {
try {
return future.get();
} catch (Exception e) {
e.printStackTrace();
}
return Null;
}
Future<MemSeg> future() {
return future;
}
String json() {
try {
MemSeg visit = future.get();
return Null == visit ? Null : one.xio.HttpMethod.UTF8.decode(avoidStarvation(visit))
.toString();
} catch (Exception e) {
e.printStackTrace();
}
return Null;
}
};
}
DocFetchActionBuilder state(Rfc822HeaderState state) {
return super.state(state);
}
DocFetchActionBuilder key(java.nio.channels.Int key) {
return super.key(key);
}
}
}
public class RevisionFetch extends DbKeysBuilder {
static Int parmsCount = 2;
construct() {
}
static RevisionFetch
$() {
return new RevisionFetch();
}
RevisionFetchActionBuilder to() {
if (parms.size >= parmsCount) { return new RevisionFetchActionBuilder(); }
throw new IllegalArgumentException("required parameters are: [db, docId]");
}
RevisionFetch db(java.lang.String stringParam) {
parms.put(DbKeys.etype.db, stringParam);
return this;
}
RevisionFetch docId(java.lang.String stringParam) {
parms.put(DbKeys.etype.docId, stringParam);
return this;
}
public service RevisionFetchTerminalBuilder extends TerminalBuilder {
String json();
Future<MemSeg> future();
}
public class RevisionFetchActionBuilder extends ActionBuilder {
construct() {
super();
}
RevisionFetchTerminalBuilder fire() {
return new RevisionFetchTerminalBuilder() {
Future<MemSeg> future =
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<MemSeg>() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
java.nio.MemSeg call() {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
return rxf.server.driver.CouchMetaDriver.RevisionFetch.visit(dbKeysBuilder,
actionBuilder);
}
});
String json() {
try {
MemSeg visit = future.get();
return Null == visit ? Null : one.xio.HttpMethod.UTF8.decode(avoidStarvation(visit))
.toString();
} catch (Exception e) {
e.printStackTrace();
}
return Null;
}
Future<MemSeg> future() {
return future;
}
};
}
RevisionFetchActionBuilder state(Rfc822HeaderState state) {
return super.state(state);
}
RevisionFetchActionBuilder key(java.nio.channels.Int key) {
return super.key(key);
}
}
}
public class DocPersist extends DbKeysBuilder {
static Int parmsCount = 2;
construct() {
}
static DocPersist
$() {
return new DocPersist();
}
DocPersistActionBuilder to() {
if (parms.size >= parmsCount) { return new DocPersistActionBuilder(); }
throw new IllegalArgumentException("required parameters are: [db, validjson]");
}
DocPersist db(java.lang.String stringParam) {
parms.put(DbKeys.etype.db, stringParam);
return this;
}
DocPersist validjson(java.lang.String stringParam) {
parms.put(DbKeys.etype.validjson, stringParam);
return this;
}
DocPersist docId(java.lang.String stringParam) {
parms.put(DbKeys.etype.docId, stringParam);
return this;
}
DocPersist rev(java.lang.String stringParam) {
parms.put(DbKeys.etype.rev, stringParam);
return this;
}
public service DocPersistTerminalBuilder extends TerminalBuilder {
CouchTx tx();

void oneWay();
Future<MemSeg> future();
}
public class DocPersistActionBuilder extends ActionBuilder {
construct() {
super();
}
DocPersistTerminalBuilder fire() {
return new DocPersistTerminalBuilder() {
Future<MemSeg> future =
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<MemSeg>() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
java.nio.MemSeg call() {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
return rxf.server.driver.CouchMetaDriver.DocPersist.visit(dbKeysBuilder,
actionBuilder);
}
});
CouchTx tx() {
try {
return CouchMetaDriver.gson().fromJson(
one.xio.HttpMethod.UTF8.decode(future.get()).toString(), CouchTx.class);
} catch (Exception e) {
if (rxf.server.BlobAntiPatternObject.DEBUG_SENDJSON) { e.printStackTrace(); }
}
return Null;
}

void oneWay() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Runnable() {
void run() {
try {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
future.get();
} catch (Exception e) {
e.printStackTrace();
}
}
});
}
Future<MemSeg> future() {
return future;
}
};
}
DocPersistActionBuilder state(Rfc822HeaderState state) {
return super.state(state);
}
DocPersistActionBuilder key(java.nio.channels.Int key) {
return super.key(key);
}
}
}
public class DocDelete extends DbKeysBuilder {
static Int parmsCount = 3;
construct() {
}
static DocDelete
$() {
return new DocDelete();
}
DocDeleteActionBuilder to() {
if (parms.size >= parmsCount) { return new DocDeleteActionBuilder(); }
throw new IllegalArgumentException("required parameters are: [db, docId, rev]");
}
DocDelete db(java.lang.String stringParam) {
parms.put(DbKeys.etype.db, stringParam);
return this;
}
DocDelete docId(java.lang.String stringParam) {
parms.put(DbKeys.etype.docId, stringParam);
return this;
}
DocDelete rev(java.lang.String stringParam) {
parms.put(DbKeys.etype.rev, stringParam);
return this;
}
public service DocDeleteTerminalBuilder extends TerminalBuilder {
CouchTx tx();

void oneWay();
Future<MemSeg> future();
}
public class DocDeleteActionBuilder extends ActionBuilder {
construct() {
super();
}
DocDeleteTerminalBuilder fire() {
return new DocDeleteTerminalBuilder() {
Future<MemSeg> future =
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<MemSeg>() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
java.nio.MemSeg call() {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
return rxf.server.driver.CouchMetaDriver.DocDelete.visit(dbKeysBuilder,
actionBuilder);
}
});
CouchTx tx() {
try {
return CouchMetaDriver.gson().fromJson(
one.xio.HttpMethod.UTF8.decode(future.get()).toString(), CouchTx.class);
} catch (Exception e) {
if (rxf.server.BlobAntiPatternObject.DEBUG_SENDJSON) { e.printStackTrace(); }
}
return Null;
}

void oneWay() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Runnable() {
void run() {
try {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
future.get();
} catch (Exception e) {
e.printStackTrace();
}
}
});
}
Future<MemSeg> future() {
return future;
}
};
}
DocDeleteActionBuilder state(Rfc822HeaderState state) {
return super.state(state);
}
DocDeleteActionBuilder key(java.nio.channels.Int key) {
return super.key(key);
}
}
}
public class DesignDocFetch extends DbKeysBuilder {
static Int parmsCount = 2;
construct() {
}
static DesignDocFetch
$() {
return new DesignDocFetch();
}
DesignDocFetchActionBuilder to() {
if (parms.size >= parmsCount) { return new DesignDocFetchActionBuilder(); }
throw new IllegalArgumentException("required parameters are: [db, designDocId]");
}
DesignDocFetch db(java.lang.String stringParam) {
parms.put(DbKeys.etype.db, stringParam);
return this;
}
DesignDocFetch designDocId(java.lang.String stringParam) {
parms.put(DbKeys.etype.designDocId, stringParam);
return this;
}
public service DesignDocFetchTerminalBuilder extends TerminalBuilder {
java.nio.MemSeg pojo();
Future<MemSeg> future();
String json();
}
public class DesignDocFetchActionBuilder extends ActionBuilder {
construct() {
super();
}
DesignDocFetchTerminalBuilder fire() {
return new DesignDocFetchTerminalBuilder() {
Future<MemSeg> future =
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<MemSeg>() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
java.nio.MemSeg call() {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
return rxf.server.driver.CouchMetaDriver.DesignDocFetch.visit(dbKeysBuilder,
actionBuilder);
}
});
java.nio.MemSeg pojo() {
try {
return future.get();
} catch (Exception e) {
e.printStackTrace();
}
return Null;
}
Future<MemSeg> future() {
return future;
}
String json() {
try {
MemSeg visit = future.get();
return Null == visit ? Null : one.xio.HttpMethod.UTF8.decode(avoidStarvation(visit))
.toString();
} catch (Exception e) {
e.printStackTrace();
}
return Null;
}
};
}
DesignDocFetchActionBuilder state(Rfc822HeaderState state) {
return super.state(state);
}
DesignDocFetchActionBuilder key(java.nio.channels.Int key) {
return super.key(key);
}
}
}

public class ViewFetch extends DbKeysBuilder {
static Int parmsCount = 2;
construct() {
}
static ViewFetch
$() {
return new ViewFetch();
}
ViewFetchActionBuilder to() {
if (parms.size >= parmsCount) { return new ViewFetchActionBuilder(); }
throw new IllegalArgumentException("required parameters are: [db, view]");
}
ViewFetch db(java.lang.String stringParam) {
parms.put(DbKeys.etype.db, stringParam);
return this;
}
ViewFetch view(java.lang.String stringParam) {
parms.put(DbKeys.etype.view, stringParam);
return this;
}
ViewFetch type(java.lang.reflect.Type typeParam) {
parms.put(DbKeys.etype.type, typeParam);
return this;
}
ViewFetch keyType(java.lang.reflect.Type typeParam) {
parms.put(DbKeys.etype.keyType, typeParam);
return this;
}
public service ViewFetchTerminalBuilder extends TerminalBuilder {
rxf.server.CouchResultSet rows();
Future<MemSeg> future();
void continuousFeed();
}
public class ViewFetchActionBuilder extends ActionBuilder {
construct() {
super();
}
ViewFetchTerminalBuilder fire() {
return new ViewFetchTerminalBuilder() {
Future<MemSeg> future =
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<MemSeg>() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
java.nio.MemSeg call() {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
return CouchMetaDriver.ViewFetch.visit(dbKeysBuilder, actionBuilder);
}
});
rxf.server.CouchResultSet rows() {
try {
MemSeg buf = future.get();

return CouchMetaDriver.gson().fromJson(
one.xio.HttpMethod.UTF8.decode(avoidStarvation(buf)).toString(),
new java.lang.reflect.ParameterizedType() {
Type getRawType() {
return CouchResultSet.class;
}
Type getOwnerType() {
return Null;
}
Type[] getActualTypeArguments() {
    Type key = ViewFetch.this.get(DbKeys.etype.keyType);
    Type[] t = new Type[2];
    if (key == Null) {
        t[0] = Object.class;
    } else {
        t[0] = key;
    }
    t[1] = ViewFetch.this.get(DbKeys.etype.type);
    return t;
}
});
} catch (Exception e) {
e.printStackTrace();
}
return Null;
}
Future<MemSeg> future() {
return future;
}
void continuousFeed() {
throw new AbstractMethodError();
}
};
}
ViewFetchActionBuilder state(Rfc822HeaderState state) {
return super.state(state);
}
ViewFetchActionBuilder key(java.nio.channels.Int key) {
return super.key(key);
}
}
}
public class JsonSend extends DbKeysBuilder {
static Int parmsCount = 2;
construct() {
}
static JsonSend
$() {
return new JsonSend();
}
JsonSendActionBuilder to() {
if (parms.size >= parmsCount) { return new JsonSendActionBuilder(); }
throw new IllegalArgumentException("required parameters are: [opaque, validjson]");
}
JsonSend opaque(java.lang.String stringParam) {
parms.put(DbKeys.etype.opaque, stringParam);
return this;
}
JsonSend validjson(java.lang.String stringParam) {
parms.put(DbKeys.etype.validjson, stringParam);
return this;
}
JsonSend type(java.lang.reflect.Type typeParam) {
parms.put(DbKeys.etype.type, typeParam);
return this;
}
JsonSend keyType(java.lang.reflect.Type typeParam) {
parms.put(DbKeys.etype.keyType, typeParam);
return this;
}
public service JsonSendTerminalBuilder extends TerminalBuilder {
CouchTx tx();

void oneWay();
rxf.server.CouchResultSet rows();
String json();
Future<MemSeg> future();
void continuousFeed();
}
public class JsonSendActionBuilder extends ActionBuilder {
construct() {
super();
}
JsonSendTerminalBuilder fire() {
return new JsonSendTerminalBuilder() {
Future<MemSeg> future =
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<MemSeg>() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
java.nio.MemSeg call() {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
return rxf.server.driver.CouchMetaDriver.JsonSend.visit(dbKeysBuilder,
actionBuilder);
}
});
CouchTx tx() {
try {
return CouchMetaDriver.gson().fromJson(
one.xio.HttpMethod.UTF8.decode(future.get()).toString(), CouchTx.class);
} catch (Exception e) {
if (rxf.server.BlobAntiPatternObject.DEBUG_SENDJSON) { e.printStackTrace(); }
}
return Null;
}

void oneWay() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Runnable() {
void run() {
try {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
future.get();
} catch (Exception e) {
e.printStackTrace();
}
}
});
}
rxf.server.CouchResultSet rows() {
try {
return CouchMetaDriver.gson().fromJson(
one.xio.HttpMethod.UTF8.decode(avoidStarvation(future.get())).toString(),
new java.lang.reflect.ParameterizedType() {
Type getRawType() {
return CouchResultSet.class;
}
Type getOwnerType() {
return Null;
}
Type[] getActualTypeArguments() {
Type key = JsonSend.this.get(DbKeys.etype.keyType);
Type[] t =
[
key == Null ? Object : key,
JsonSend.this.get(DbKeys.etype.type)];
return t;
}
});
} catch (Exception e) {
e.printStackTrace();
}
return Null;
}
String json() {
try {
MemSeg visit = future.get();
return Null == visit ? Null : one.xio.HttpMethod.UTF8.decode(avoidStarvation(visit))
.toString();
} catch (Exception e) {
e.printStackTrace();
}
return Null;
}
Future<MemSeg> future() {
return future;
}
void continuousFeed() {
throw new AbstractMethodError();
}
};
}
JsonSendActionBuilder state(Rfc822HeaderState state) {
return super.state(state);
}
JsonSendActionBuilder key(java.nio.channels.Int key) {
return super.key(key);
}
}
}
public class BlobSend extends DbKeysBuilder {
static Int parmsCount = 5;
construct() {
}
static BlobSend
$() {
return new BlobSend();
}
BlobSendActionBuilder to() {
if (parms.size >= parmsCount) { return new BlobSendActionBuilder(); }
throw new IllegalArgumentException(
"required parameters are: [blob, db, docId, rev, attachname]");
}
BlobSend blob(java.nio.MemSeg bytebufferParam) {
parms.put(DbKeys.etype.blob, bytebufferParam);
return this;
}
BlobSend db(java.lang.String stringParam) {
parms.put(DbKeys.etype.db, stringParam);
return this;
}
BlobSend docId(java.lang.String stringParam) {
parms.put(DbKeys.etype.docId, stringParam);
return this;
}
BlobSend rev(java.lang.String stringParam) {
parms.put(DbKeys.etype.rev, stringParam);
return this;
}
BlobSend attachname(java.lang.String stringParam) {
parms.put(DbKeys.etype.attachname, stringParam);
return this;
}
BlobSend mimetypeEnum(one.xio.MimeType mimetypeParam) {
parms.put(DbKeys.etype.mimetypeEnum, mimetypeParam);
return this;
}
BlobSend mimetype(java.lang.String stringParam) {
parms.put(DbKeys.etype.mimetype, stringParam);
return this;
}
public service BlobSendTerminalBuilder extends TerminalBuilder {
CouchTx tx();
Future<MemSeg> future();

void oneWay();
}
public class BlobSendActionBuilder extends ActionBuilder {
construct() {
super();
}
BlobSendTerminalBuilder fire() {
return new BlobSendTerminalBuilder() {
Future<MemSeg> future =
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<MemSeg>() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
java.nio.MemSeg call() {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
return rxf.server.driver.CouchMetaDriver.BlobSend.visit(dbKeysBuilder,
actionBuilder);
}
});
CouchTx tx() {
try {
return CouchMetaDriver.gson().fromJson(
one.xio.HttpMethod.UTF8.decode(future.get()).toString(), CouchTx.class);
} catch (Exception e) {
if (rxf.server.BlobAntiPatternObject.DEBUG_SENDJSON) { e.printStackTrace(); }
}
return Null;
}
Future<MemSeg> future() {
return future;
}

void oneWay() {
DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
ActionBuilder actionBuilder = ActionBuilder.get();
BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Runnable() {
void run() {
try {
DbKeysBuilder.currentKeys.set(dbKeysBuilder);
ActionBuilder.currentAction.set(actionBuilder);
future.get();
} catch (Exception e) {
e.printStackTrace();
}
}
});
}
};
}
BlobSendActionBuilder state(Rfc822HeaderState state) {
return super.state(state);
}
BlobSendActionBuilder key(java.nio.channels.Int key) {
return super.key(key);
}
}
}
}
