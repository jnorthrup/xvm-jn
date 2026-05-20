public enum DbTerminal {

oneWay {
String builder(CouchMetaDriver couchDriver, etype[] parms, Boolean implementation) {
return " "
+ (implementation ? " " : "")
+ "void "
+ name()
+ "()"
+ (implementation
? "{\n DbKeysBuilder dbKeysBuilder=(DbKeysBuilder)DbKeysBuilder.get();\n"
+ "ActionBuilder actionBuilder=(ActionBuilder )ActionBuilder.get();\n"
+ "\nBlobAntiPatternObject.EXECUTOR_SERVICE.submit(new Runnable(){\n"
+ "\npublic void run(){\n"
+ " try{\n\n DbKeysBuilder.currentKeys.set(dbKeysBuilder); \n ActionBuilder.currentAction.set(actionBuilder); \nfuture.get();"
+ "\n}catch (Exception e){\n e.printStackTrace();}\n }\n });\n}" : ";");
}
},

rows {
String builder(CouchMetaDriver couchDriver, etype[] parms, Boolean implementation) {
String visitor = "rxf.server.driver.CouchMetaDriver." + couchDriver;
String cmdName = couchDriver.name();
String s =
"{\n"
+ " try {\n"
+ " return GSON.fromJson(one.xio.HttpMethod.UTF8.decode(avoidStarvation("
+ visitor
+ ".visit())).toString(),\n"
+ " new java.lang.reflect.ParameterizedType() {\n"
+ " Type getRawType() {\n"
+ " return CouchResultSet.class;\n"
+ " }\n"
+ "\n"
+ " Type getOwnerType() {\n"
+ " return Null;\n"
+ " }\n"
+ "\n"
+ " Type[] getActualTypeArguments() {\n"
+ " "
+ " Type key = (Type)"
+ cmdName
+ ".this.get(DbKeys.etype.keyType);\n"
+ " Type[]t={key == Null ? Object.class : key, (Type)"
+ cmdName
+ ".this.get(DbKeys.etype.type)};\n"
+ " return t;\n"
+ " }\n"
+ " });\n"
+ " } catch (Exception e) {\n"
+ " e.printStackTrace();\n"
+ " }\n"
+ " return Null;\n" + " }";
return (implementation ? " " : "") + " String json()" + (implementation ? s : ";");
}
};

static String BIG_EMPTY_PLACE = "throw new AbstractMethodError()";
String builder(DbTerminal couchDriver, etype[] parms, Boolean implementation);
}