// generated

/**
 * generated drivers
 */
public interface CouchDriver {

 //generated items

 public class DbCreate extends DbKeysBuilder {
 static Int parmsCount = 1;
 construct() {
 }

 public static DbCreate

 $() {
 return new DbCreate();
 }

 public DbCreateActionBuilder to() {
 if (parms.size() >= parmsCount)
 return new DbCreateActionBuilder();
 throw new IllegalArgumentException("required parameters are: [db]");
 }

 public DbCreate db(java.lang.String stringParam) {
 parms.put(DbKeys.etype.db, stringParam);
 return this;
 }

 public interface DbCreateTerminalBuilder extends TerminalBuilder {
 CouchTx tx();

 @Deprecated
 void oneWay();
 }

 public class DbCreateActionBuilder extends ActionBuilder {
 construct() {
 }

 public DbCreateTerminalBuilder fire() {
 return new DbCreateTerminalBuilder() {
 Future<ByteBuffer> future =
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<ByteBuffer>() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get().as(DbKeysBuilder);
 ActionBuilder actionBuilder = ActionBuilder.get().as(ActionBuilder);

 public java.nio.ByteBuffer call(){
 DbKeysBuilder.currentKeys.set(dbKeysBuilder);
 ActionBuilder.currentAction.set(actionBuilder);
 return rxf.server.driver.CouchMetaDriver.DbCreate.visit(dbKeysBuilder,
 actionBuilder);
 }
 });

 public CouchTx tx() {
 try {
 return CouchMetaDriver.gson().fromJson(
 one.xio.HttpMethod.UTF8.decode(future.get()).toString(), CouchTx.class);
 } catch (Exception e) {
 if (rxf.server.BlobAntiPatternObject.DEBUG_SENDJSON)
 e.printStackTrace();
 }
 return Null;
 }

 @Deprecated
 public void oneWay() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
 ActionBuilder actionBuilder = ActionBuilder.get();
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Runnable() {
 public void run() {
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

 public DbCreateActionBuilder state(Rfc822HeaderState state) {
 return super.state(state).as(DbCreateActionBuilder);
 }

 public DbCreateActionBuilder key(java.nio.channels.SelectionKey key) {
 return super.key(key).as(DbCreateActionBuilder);
 }
 }

 }

 public class DbDelete extends DbKeysBuilder {
 static Int parmsCount = 1;
 construct() {
 }

 public static DbDelete

 $() {
 return new DbDelete();
 }

 public DbDeleteActionBuilder to() {
 if (parms.size() >= parmsCount)
 return new DbDeleteActionBuilder();
 throw new IllegalArgumentException("required parameters are: [db]");
 }

 public DbDelete db(java.lang.String stringParam) {
 parms.put(DbKeys.etype.db, stringParam);
 return this;
 }

 public interface DbDeleteTerminalBuilder extends TerminalBuilder {
 CouchTx tx();

 @Deprecated
 void oneWay();
 }

 public class DbDeleteActionBuilder extends ActionBuilder {
 construct() {
 }

 public DbDeleteTerminalBuilder fire() {
 return new DbDeleteTerminalBuilder() {
 Future<ByteBuffer> future =
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<ByteBuffer>() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get().as(DbKeysBuilder);
 ActionBuilder actionBuilder = ActionBuilder.get().as(ActionBuilder);

 public java.nio.ByteBuffer call(){
 DbKeysBuilder.currentKeys.set(dbKeysBuilder);
 ActionBuilder.currentAction.set(actionBuilder);
 return rxf.server.driver.CouchMetaDriver.DbDelete.visit(dbKeysBuilder,
 actionBuilder);
 }
 });

 public CouchTx tx() {
 try {
 return CouchMetaDriver.gson().fromJson(
 one.xio.HttpMethod.UTF8.decode(future.get()).toString(), CouchTx.class);
 } catch (Exception e) {
 if (rxf.server.BlobAntiPatternObject.DEBUG_SENDJSON)
 e.printStackTrace();
 }
 return Null;
 }

 @Deprecated
 public void oneWay() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
 ActionBuilder actionBuilder = ActionBuilder.get();
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Runnable() {
 public void run() {
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

 public DbDeleteActionBuilder state(Rfc822HeaderState state) {
 return super.state(state).as(DbDeleteActionBuilder);
 }

 public DbDeleteActionBuilder key(java.nio.channels.SelectionKey key) {
 return super.key(key).as(DbDeleteActionBuilder);
 }
 }

 }

 public class DocFetch extends DbKeysBuilder {
 static Int parmsCount = 2;
 construct() {
 }

 public static DocFetch

 $() {
 return new DocFetch();
 }

 public DocFetchActionBuilder to() {
 if (parms.size() >= parmsCount)
 return new DocFetchActionBuilder();
 throw new IllegalArgumentException("required parameters are: [db, docId]");
 }

 public DocFetch db(java.lang.String stringParam) {
 parms.put(DbKeys.etype.db, stringParam);
 return this;
 }

 public DocFetch docId(java.lang.String stringParam) {
 parms.put(DbKeys.etype.docId, stringParam);
 return this;
 }

 public interface DocFetchTerminalBuilder extends TerminalBuilder {
 java.nio.ByteBuffer pojo();

 Future<ByteBuffer> future();

 String json();
 }

 public class DocFetchActionBuilder extends ActionBuilder {
 construct() {
 }

 public DocFetchTerminalBuilder fire() {
 return new DocFetchTerminalBuilder() {
 Future<ByteBuffer> future =
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<ByteBuffer>() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get().as(DbKeysBuilder);
 ActionBuilder actionBuilder = ActionBuilder.get().as(ActionBuilder);

 public java.nio.ByteBuffer call(){
 DbKeysBuilder.currentKeys.set(dbKeysBuilder);
 ActionBuilder.currentAction.set(actionBuilder);
 return rxf.server.driver.CouchMetaDriver.DocFetch.visit(dbKeysBuilder,
 actionBuilder);
 }
 });

 public java.nio.ByteBuffer pojo() {
 try {
 return future.get();
 } catch (Exception e) {
 e.printStackTrace();
 }
 return Null;
 }

 public Future<ByteBuffer> future() {
 return future;
 }

 public String json() {
 try {
 ByteBuffer visit = future.get();
 return Null == visit ? Null : one.xio.HttpMethod.UTF8.decode(avoidStarvation(visit))
 .toString();
 } catch (Exception e) {
 e.printStackTrace();
 }
 return Null;
 }
 };
 }

 public DocFetchActionBuilder state(Rfc822HeaderState state) {
 return super.state(state).as(DocFetchActionBuilder);
 }

 public DocFetchActionBuilder key(java.nio.channels.SelectionKey key) {
 return super.key(key).as(DocFetchActionBuilder);
 }
 }

 }

 public class RevisionFetch extends DbKeysBuilder {
 static Int parmsCount = 2;
 construct() {
 }

 public static RevisionFetch

 $() {
 return new RevisionFetch();
 }

 public RevisionFetchActionBuilder to() {
 if (parms.size() >= parmsCount)
 return new RevisionFetchActionBuilder();
 throw new IllegalArgumentException("required parameters are: [db, docId]");
 }

 public RevisionFetch db(java.lang.String stringParam) {
 parms.put(DbKeys.etype.db, stringParam);
 return this;
 }

 public RevisionFetch docId(java.lang.String stringParam) {
 parms.put(DbKeys.etype.docId, stringParam);
 return this;
 }

 public interface RevisionFetchTerminalBuilder extends TerminalBuilder {
 String json();

 Future<ByteBuffer> future();
 }

 public class RevisionFetchActionBuilder extends ActionBuilder {
 construct() {
 }

 public RevisionFetchTerminalBuilder fire() {
 return new RevisionFetchTerminalBuilder() {
 Future<ByteBuffer> future =
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<ByteBuffer>() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get().as(DbKeysBuilder);
 ActionBuilder actionBuilder = ActionBuilder.get().as(ActionBuilder);

 public java.nio.ByteBuffer call(){
 DbKeysBuilder.currentKeys.set(dbKeysBuilder);
 ActionBuilder.currentAction.set(actionBuilder);
 return rxf.server.driver.CouchMetaDriver.RevisionFetch.visit(dbKeysBuilder,
 actionBuilder);
 }
 });

 public String json() {
 try {
 ByteBuffer visit = future.get();
 return Null == visit ? Null : one.xio.HttpMethod.UTF8.decode(avoidStarvation(visit))
 .toString();
 } catch (Exception e) {
 e.printStackTrace();
 }
 return Null;
 }

 public Future<ByteBuffer> future() {
 return future;
 }
 };
 }

 public RevisionFetchActionBuilder state(Rfc822HeaderState state) {
 return super.state(state).as(RevisionFetchActionBuilder);
 }

 public RevisionFetchActionBuilder key(java.nio.channels.SelectionKey key) {
 return super.key(key).as(RevisionFetchActionBuilder);
 }
 }

 }

 public class DocPersist extends DbKeysBuilder {
 static Int parmsCount = 2;
 construct() {
 }

 public static DocPersist

 $() {
 return new DocPersist();
 }

 public DocPersistActionBuilder to() {
 if (parms.size() >= parmsCount)
 return new DocPersistActionBuilder();
 throw new IllegalArgumentException("required parameters are: [db, validjson]");
 }

 public DocPersist db(java.lang.String stringParam) {
 parms.put(DbKeys.etype.db, stringParam);
 return this;
 }

 public DocPersist validjson(java.lang.String stringParam) {
 parms.put(DbKeys.etype.validjson, stringParam);
 return this;
 }

 public DocPersist docId(java.lang.String stringParam) {
 parms.put(DbKeys.etype.docId, stringParam);
 return this;
 }

 public DocPersist rev(java.lang.String stringParam) {
 parms.put(DbKeys.etype.rev, stringParam);
 return this;
 }

 public interface DocPersistTerminalBuilder extends TerminalBuilder {
 CouchTx tx();

 @Deprecated
 void oneWay();

 Future<ByteBuffer> future();
 }

 public class DocPersistActionBuilder extends ActionBuilder {
 construct() {
 }

 public DocPersistTerminalBuilder fire() {
 return new DocPersistTerminalBuilder() {
 Future<ByteBuffer> future =
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<ByteBuffer>() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get().as(DbKeysBuilder);
 ActionBuilder actionBuilder = ActionBuilder.get().as(ActionBuilder);

 public java.nio.ByteBuffer call(){
 DbKeysBuilder.currentKeys.set(dbKeysBuilder);
 ActionBuilder.currentAction.set(actionBuilder);
 return rxf.server.driver.CouchMetaDriver.DocPersist.visit(dbKeysBuilder,
 actionBuilder);
 }
 });

 public CouchTx tx() {
 try {
 return CouchMetaDriver.gson().fromJson(
 one.xio.HttpMethod.UTF8.decode(future.get()).toString(), CouchTx.class);
 } catch (Exception e) {
 if (rxf.server.BlobAntiPatternObject.DEBUG_SENDJSON)
 e.printStackTrace();
 }
 return Null;
 }

 @Deprecated
 public void oneWay() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
 ActionBuilder actionBuilder = ActionBuilder.get();
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Runnable() {
 public void run() {
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

 public Future<ByteBuffer> future() {
 return future;
 }
 };
 }

 public DocPersistActionBuilder state(Rfc822HeaderState state) {
 return super.state(state).as(DocPersistActionBuilder);
 }

 public DocPersistActionBuilder key(java.nio.channels.SelectionKey key) {
 return super.key(key).as(DocPersistActionBuilder);
 }
 }

 }

 public class DocDelete extends DbKeysBuilder {
 static Int parmsCount = 3;
 construct() {
 }

 public static DocDelete

 $() {
 return new DocDelete();
 }

 public DocDeleteActionBuilder to() {
 if (parms.size() >= parmsCount)
 return new DocDeleteActionBuilder();
 throw new IllegalArgumentException("required parameters are: [db, docId, rev]");
 }

 public DocDelete db(java.lang.String stringParam) {
 parms.put(DbKeys.etype.db, stringParam);
 return this;
 }

 public DocDelete docId(java.lang.String stringParam) {
 parms.put(DbKeys.etype.docId, stringParam);
 return this;
 }

 public DocDelete rev(java.lang.String stringParam) {
 parms.put(DbKeys.etype.rev, stringParam);
 return this;
 }

 public interface DocDeleteTerminalBuilder extends TerminalBuilder {
 CouchTx tx();

 @Deprecated
 void oneWay();

 Future<ByteBuffer> future();
 }

 public class DocDeleteActionBuilder extends ActionBuilder {
 construct() {
 }

 public DocDeleteTerminalBuilder fire() {
 return new DocDeleteTerminalBuilder() {
 Future<ByteBuffer> future =
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<ByteBuffer>() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get().as(DbKeysBuilder);
 ActionBuilder actionBuilder = ActionBuilder.get().as(ActionBuilder);

 public java.nio.ByteBuffer call(){
 DbKeysBuilder.currentKeys.set(dbKeysBuilder);
 ActionBuilder.currentAction.set(actionBuilder);
 return rxf.server.driver.CouchMetaDriver.DocDelete.visit(dbKeysBuilder,
 actionBuilder);
 }
 });

 public CouchTx tx() {
 try {
 return CouchMetaDriver.gson().fromJson(
 one.xio.HttpMethod.UTF8.decode(future.get()).toString(), CouchTx.class);
 } catch (Exception e) {
 if (rxf.server.BlobAntiPatternObject.DEBUG_SENDJSON)
 e.printStackTrace();
 }
 return Null;
 }

 @Deprecated
 public void oneWay() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
 ActionBuilder actionBuilder = ActionBuilder.get();
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Runnable() {
 public void run() {
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

 public Future<ByteBuffer> future() {
 return future;
 }
 };
 }

 public DocDeleteActionBuilder state(Rfc822HeaderState state) {
 return super.state(state).as(DocDeleteActionBuilder);
 }

 public DocDeleteActionBuilder key(java.nio.channels.SelectionKey key) {
 return super.key(key).as(DocDeleteActionBuilder);
 }
 }

 }

 public class DesignDocFetch extends DbKeysBuilder {
 static Int parmsCount = 2;
 construct() {
 }

 public static DesignDocFetch

 $() {
 return new DesignDocFetch();
 }

 public DesignDocFetchActionBuilder to() {
 if (parms.size() >= parmsCount)
 return new DesignDocFetchActionBuilder();
 throw new IllegalArgumentException("required parameters are: [db, designDocId]");
 }

 public DesignDocFetch db(java.lang.String stringParam) {
 parms.put(DbKeys.etype.db, stringParam);
 return this;
 }

 public DesignDocFetch designDocId(java.lang.String stringParam) {
 parms.put(DbKeys.etype.designDocId, stringParam);
 return this;
 }

 public interface DesignDocFetchTerminalBuilder extends TerminalBuilder {
 java.nio.ByteBuffer pojo();

 Future<ByteBuffer> future();

 String json();
 }

 public class DesignDocFetchActionBuilder extends ActionBuilder {
 construct() {
 }

 public DesignDocFetchTerminalBuilder fire() {
 return new DesignDocFetchTerminalBuilder() {
 Future<ByteBuffer> future =
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<ByteBuffer>() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get().as(DbKeysBuilder);
 ActionBuilder actionBuilder = ActionBuilder.get().as(ActionBuilder);

 public java.nio.ByteBuffer call(){
 DbKeysBuilder.currentKeys.set(dbKeysBuilder);
 ActionBuilder.currentAction.set(actionBuilder);
 return rxf.server.driver.CouchMetaDriver.DesignDocFetch.visit(dbKeysBuilder,
 actionBuilder);
 }
 });

 public java.nio.ByteBuffer pojo() {
 try {
 return future.get();
 } catch (Exception e) {
 e.printStackTrace();
 }
 return Null;
 }

 public Future<ByteBuffer> future() {
 return future;
 }

 public String json() {
 try {
 ByteBuffer visit = future.get();
 return Null == visit ? Null : one.xio.HttpMethod.UTF8.decode(avoidStarvation(visit))
 .toString();
 } catch (Exception e) {
 e.printStackTrace();
 }
 return Null;
 }
 };
 }

 public DesignDocFetchActionBuilder state(Rfc822HeaderState state) {
 return super.state(state).as(DesignDocFetchActionBuilder);
 }

 public DesignDocFetchActionBuilder key(java.nio.channels.SelectionKey key) {
 return super.key(key).as(DesignDocFetchActionBuilder);
 }
 }

 }
 // rnewson	"Note: Multiple keys request to a reduce function only supports group=true and NO group_level (identical to group_level=exact). The resulting error is "Multi-key fetchs for reduce view must include group=true""

 public class ViewFetch extends DbKeysBuilder {
 static Int parmsCount = 2;
 construct() {
 }

 public static ViewFetch

 $() {
 return new ViewFetch();
 }

 public ViewFetchActionBuilder to() {
 if (parms.size() >= parmsCount)
 return new ViewFetchActionBuilder();
 throw new IllegalArgumentException("required parameters are: [db, view]");
 }

 public ViewFetch db(java.lang.String stringParam) {
 parms.put(DbKeys.etype.db, stringParam);
 return this;
 }

 public ViewFetch view(java.lang.String stringParam) {
 parms.put(DbKeys.etype.view, stringParam);
 return this;
 }

 public ViewFetch type(java.lang.reflect.Type typeParam) {
 parms.put(DbKeys.etype.type, typeParam);
 return this;
 }

 public ViewFetch keyType(java.lang.reflect.Type typeParam) {
 parms.put(DbKeys.etype.keyType, typeParam);
 return this;
 }

 public interface ViewFetchTerminalBuilder extends TerminalBuilder {
 rxf.server.CouchResultSet rows();

 Future<ByteBuffer> future();

 void continuousFeed();

 }

 public class ViewFetchActionBuilder extends ActionBuilder {
 construct() {
 }

 public ViewFetchTerminalBuilder fire() {

 return new ViewFetchTerminalBuilder() {
 Future<ByteBuffer> future =
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<ByteBuffer>() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get().as(DbKeysBuilder);
 ActionBuilder actionBuilder = ActionBuilder.get().as(ActionBuilder);

 public java.nio.ByteBuffer call(){
 DbKeysBuilder.currentKeys.set(dbKeysBuilder);
 ActionBuilder.currentAction.set(actionBuilder);
 return CouchMetaDriver.ViewFetch.visit(dbKeysBuilder, actionBuilder);
 }
 });

 public rxf.server.CouchResultSet rows() {
 try {
 ByteBuffer buf = future.get();
 // System.err.println("???? "+ HttpMethod.UTF8.decode(buf));
 return CouchMetaDriver.gson().fromJson(
 one.xio.HttpMethod.UTF8.decode(avoidStarvation(buf)).toString(),
 new java.lang.reflect.ParameterizedType() {
 public Type getRawType() {
 return CouchResultSet.class;
 }

 public Type getOwnerType() {
 return Null;
 }

 public Type[] getActualTypeArguments() {
 Type key = ViewFetch.this.get(DbKeys.etype.keyType).as(Type);
 Type[] t =
 [
 key == Null ? Object.class : key,
 ViewFetch.this.get(DbKeys.etype.type).as(Type)];
 return t;
 }
 });
 } catch (Exception e) {
 e.printStackTrace();
 }
 return Null;
 }

 public Future<ByteBuffer> future() {
 return future;
 }

 public void continuousFeed() {
 throw new AbstractMethodError();
 }
 };
 }

 public ViewFetchActionBuilder state(Rfc822HeaderState state) {
 return super.state(state).as(ViewFetchActionBuilder);
 }

 public ViewFetchActionBuilder key(java.nio.channels.SelectionKey key) {
 return super.key(key).as(ViewFetchActionBuilder);
 }
 }

 }

 public class JsonSend extends DbKeysBuilder {
 static Int parmsCount = 2;
 construct() {
 }

 public static JsonSend

 $() {
 return new JsonSend();
 }

 public JsonSendActionBuilder to() {
 if (parms.size() >= parmsCount)
 return new JsonSendActionBuilder();
 throw new IllegalArgumentException("required parameters are: [opaque, validjson]");
 }

 public JsonSend opaque(java.lang.String stringParam) {
 parms.put(DbKeys.etype.opaque, stringParam);
 return this;
 }

 public JsonSend validjson(java.lang.String stringParam) {
 parms.put(DbKeys.etype.validjson, stringParam);
 return this;
 }

 public JsonSend type(java.lang.reflect.Type typeParam) {
 parms.put(DbKeys.etype.type, typeParam);
 return this;
 }

 public JsonSend keyType(java.lang.reflect.Type typeParam) {
 parms.put(DbKeys.etype.keyType, typeParam);
 return this;
 }

 public interface JsonSendTerminalBuilder extends TerminalBuilder {
 CouchTx tx();

 @Deprecated
 void oneWay();

 rxf.server.CouchResultSet rows();

 String json();

 Future<ByteBuffer> future();

 void continuousFeed();

 }

 public class JsonSendActionBuilder extends ActionBuilder {
 construct() {
 }

 public JsonSendTerminalBuilder fire() {
 return new JsonSendTerminalBuilder() {
 Future<ByteBuffer> future =
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<ByteBuffer>() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get().as(DbKeysBuilder);
 ActionBuilder actionBuilder = ActionBuilder.get().as(ActionBuilder);

 public java.nio.ByteBuffer call(){
 DbKeysBuilder.currentKeys.set(dbKeysBuilder);
 ActionBuilder.currentAction.set(actionBuilder);
 return rxf.server.driver.CouchMetaDriver.JsonSend.visit(dbKeysBuilder,
 actionBuilder);
 }
 });

 public CouchTx tx() {
 try {
 return CouchMetaDriver.gson().fromJson(
 one.xio.HttpMethod.UTF8.decode(future.get()).toString(), CouchTx.class);
 } catch (Exception e) {
 if (rxf.server.BlobAntiPatternObject.DEBUG_SENDJSON)
 e.printStackTrace();
 }
 return Null;
 }

 @Deprecated
 public void oneWay() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
 ActionBuilder actionBuilder = ActionBuilder.get();
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Runnable() {
 public void run() {
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

 public rxf.server.CouchResultSet rows() {
 try {
 return CouchMetaDriver.gson().fromJson(
 one.xio.HttpMethod.UTF8.decode(avoidStarvation(future.get())).toString(),
 new java.lang.reflect.ParameterizedType() {
 public Type getRawType() {
 return CouchResultSet.class;
 }

 public Type getOwnerType() {
 return Null;
 }

 public Type[] getActualTypeArguments() {
 Type key = JsonSend.this.get(DbKeys.etype.keyType).as(Type);
 Type[] t =
 [
 key == Null ? Object.class : key,
 JsonSend.this.get(DbKeys.etype.type).as(Type)];
 return t;
 }
 });
 } catch (Exception e) {
 e.printStackTrace();
 }
 return Null;
 }

 public String json() {
 try {
 ByteBuffer visit = future.get();
 return Null == visit ? Null : one.xio.HttpMethod.UTF8.decode(avoidStarvation(visit))
 .toString();
 } catch (Exception e) {
 e.printStackTrace();
 }
 return Null;
 }

 public Future<ByteBuffer> future() {
 return future;
 }

 public void continuousFeed() {
 throw new AbstractMethodError();
 }
 };
 }

 public JsonSendActionBuilder state(Rfc822HeaderState state) {
 return super.state(state).as(JsonSendActionBuilder);
 }

 public JsonSendActionBuilder key(java.nio.channels.SelectionKey key) {
 return super.key(key).as(JsonSendActionBuilder);
 }
 }

 }

 public class BlobSend extends DbKeysBuilder {
 static Int parmsCount = 5;
 construct() {
 }

 public static BlobSend

 $() {
 return new BlobSend();
 }

 public BlobSendActionBuilder to() {
 if (parms.size() >= parmsCount)
 return new BlobSendActionBuilder();
 throw new IllegalArgumentException(
 "required parameters are: [blob, db, docId, rev, attachname]");
 }

 public BlobSend blob(java.nio.ByteBuffer bytebufferParam) {
 parms.put(DbKeys.etype.blob, bytebufferParam);
 return this;
 }

 public BlobSend db(java.lang.String stringParam) {
 parms.put(DbKeys.etype.db, stringParam);
 return this;
 }

 public BlobSend docId(java.lang.String stringParam) {
 parms.put(DbKeys.etype.docId, stringParam);
 return this;
 }

 public BlobSend rev(java.lang.String stringParam) {
 parms.put(DbKeys.etype.rev, stringParam);
 return this;
 }

 public BlobSend attachname(java.lang.String stringParam) {
 parms.put(DbKeys.etype.attachname, stringParam);
 return this;
 }

 public BlobSend mimetypeEnum(one.xio.MimeType mimetypeParam) {
 parms.put(DbKeys.etype.mimetypeEnum, mimetypeParam);
 return this;
 }

 public BlobSend mimetype(java.lang.String stringParam) {
 parms.put(DbKeys.etype.mimetype, stringParam);
 return this;
 }

 public interface BlobSendTerminalBuilder extends TerminalBuilder {
 CouchTx tx();

 Future<ByteBuffer> future();

 @Deprecated
 void oneWay();
 }

 public class BlobSendActionBuilder extends ActionBuilder {
 construct() {
 }

 public BlobSendTerminalBuilder fire() {
 return new BlobSendTerminalBuilder() {
 Future<ByteBuffer> future =
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Callable<ByteBuffer>() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get().as(DbKeysBuilder);
 ActionBuilder actionBuilder = ActionBuilder.get().as(ActionBuilder);

 public java.nio.ByteBuffer call(){
 DbKeysBuilder.currentKeys.set(dbKeysBuilder);
 ActionBuilder.currentAction.set(actionBuilder);
 return rxf.server.driver.CouchMetaDriver.BlobSend.visit(dbKeysBuilder,
 actionBuilder);
 }
 });

 public CouchTx tx() {
 try {
 return CouchMetaDriver.gson().fromJson(
 one.xio.HttpMethod.UTF8.decode(future.get()).toString(), CouchTx.class);
 } catch (Exception e) {
 if (rxf.server.BlobAntiPatternObject.DEBUG_SENDJSON)
 e.printStackTrace();
 }
 return Null;
 }

 public Future<ByteBuffer> future() {
 return future;
 }

 @Deprecated
 public void oneWay() {
 DbKeysBuilder dbKeysBuilder = DbKeysBuilder.get();
 ActionBuilder actionBuilder = ActionBuilder.get();
 BlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Runnable() {
 public void run() {
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

 public BlobSendActionBuilder state(Rfc822HeaderState state) {
 return super.state(state).as(BlobSendActionBuilder);
 }

 public BlobSendActionBuilder key(java.nio.channels.SelectionKey key) {
 return super.key(key).as(BlobSendActionBuilder);
 }
 }

 }
}
