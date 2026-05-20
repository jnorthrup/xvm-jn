public enum HttpStatus {
_100("Continue"),
_101("Switching Protocols"),

_200("OK"),
_201("Created"),
_202("Accepted"),
_203("Non-Authoritative Information"),
_204("No Content"),
_205("Reset Content"),
_206("Partial Content"),
_207("Multi-Status"),

_300("Multiple Choices"),
_301("Moved Permanently"),
_302("Found"),
_303("See Other"),
_304("Not Modified"),
_305("Use Proxy"),
_306("(Reserved)"),
_307("Temporary Redirect"),

_400("Bad Request"),
_401("Unauthorized"),
_402("Payment Required"),
_403("Forbidden"),
_404("Not Found"),
_405("Method Not"),
_406("Not Acceptable"),
_407("Proxy Authentication Required"),
_408("Request Timeout"),
_409("Conflict"),
_410("Gone"),
_411("Length Required"),
_412("Precondition Failed"),
_413("Request Entity Too Large"),
_414("Request-URI Too Long"),
_415("Unsupported Media Type"),
_416("Requested Range Not Satisfiable"),
_417("Expectation Failed"),
_422("Unprocessable Entity"),
_423("Locked"),
_424("Failed Dependency"),
_5xx("Server Error"),

_500("Internal Server Error"),
_501("Not Implemented"),
_502("Bad Gateway"),
_503("Service Unavailable"),
_504("Gateway Timeout"),
_505("HTTP Version Not Supported"),
_507("Insufficient Storage");

static String caption;
construct (String cap) {
    this.caption = cap;
}
}