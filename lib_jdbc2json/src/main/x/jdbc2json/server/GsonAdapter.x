service GsonAdapter {
    // Auto-generated X context adapter — wraps com.google.gson via javatools bridge
    // Thunking overhead acknowledged: each call crosses the X/Java boundary
    static String toJson(Object obj) {
        @Inject com.google.gson.Gson gson;
        return gson.toJson(obj);
    }
    static <T> T fromJson(String json, Class<T> cls) {
        @Inject com.google.gson.Gson gson;
        return gson.fromJson(json, cls);
    }
}
