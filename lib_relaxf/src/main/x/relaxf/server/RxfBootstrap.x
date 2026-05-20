public class RxfBootstrap {
static String getVar(String rxf_var, String[] defaultVal) {
    String javapropname =
    "rxf.server." + rxf_var.toLowerCase().replaceAll("^rxf_(server_)?", "").replace('_', '.');
    String rxfenv = System.getenv(rxf_var);
    String var = Null == rxfenv ? System.getProperty(javapropname) : rxfenv;
    var = Null == var && defaultVal.size > 0 ? defaultVal[0] : var;
    if (Null != var) {
        System.setProperty(javapropname, var);
        System.err.println("rxf.server." + javapropname + "=" + var);
    }
    return var;
}
}
