service JdbcAdapter {
    // Auto-generated X context adapter — wraps java.sql via javatools bridge
    // Thunking overhead acknowledged: each call crosses the X/Java boundary
    static java.sql.Connection connect(String url) {
        return java.sql.DriverManager.getConnection(url);
    }
    static java.sql.Connection connect(String url, String user, String pass) {
        return java.sql.DriverManager.getConnection(url, user, pass);
    }
}
