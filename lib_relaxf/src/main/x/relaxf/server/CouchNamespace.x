
public service CouchNamespace {

Map<HttpMethod, Map<Pattern, Class<Object>>> NAMESPACE =
new EnumMap<HttpMethod, Map<Pattern, Class<Object>>>(HttpMethod.class);

String COUCH_DEFAULT_FS_ROOT = RxfBootstrap.getVar("RXF_SERVER_CONTENT_ROOT", "./");

String COUCH_DEFAULT_ORGNAME = RxfBootstrap.getVar("RXF_ORGNAME", "rxf_");
String getOrgName();
void setOrgname(String orgname);
void setEntityName(String entityName);
String getEntityName();
String getDefaultEntityName();
public enum ns {
orgname {

void setMe(CouchNamespace cl, String ns) {
    cl.setOrgname(ns);
}
},
entityName {

void setMe(CouchNamespace cl, String ns) {
    cl.setEntityName(ns);
}
};

void setMe(CouchNamespace cl, String ns);
}
}
