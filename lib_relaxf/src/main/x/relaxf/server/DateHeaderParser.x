public enum DateHeaderParser {

RFC1123,
RFC1036,
ISO8601,
ISOMS,
SHORT,
MED,
LONG,
FULL,
ASCTIME;

DateFormat format;
construct() {
    switch (this) {
        case RFC1123:
            format = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.getDefault());
            break;
        case RFC1036:
            format = new SimpleDateFormat("EEEE, dd-MMM-yy HH:mm:ss z", Locale.getDefault());
            break;
        case ISO8601:
            format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssz", Locale.getDefault());
            break;
        case ISOMS:
            format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSz", Locale.getDefault());
            break;
        case SHORT:
            format = new SimpleDateFormat("dd-MMM-yyyy HH:mm:ss", Locale.getDefault());
            break;
        case MED:
            format = new SimpleDateFormat("MMM dd, yyyy HH:mm:ss", Locale.getDefault());
            break;
        case LONG:
            format = new SimpleDateFormat("MMMM dd, yyyy 'at' HH:mm:ss z", Locale.getDefault());
            break;
        case FULL:
            format = DateFormat.getDateTimeInstance(DateFormat.FULL, DateFormat.FULL, Locale.getDefault());
            break;
        case ASCTIME:
            format = new SimpleDateFormat("EEE MMM d HH:mm:ss yyyy", Locale.getDefault());
            break;
        default:
            format = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.getDefault());
    }
    format.setLenient(True);
    if (BlobAntiPatternObject.isDEBUG_SENDJSON()) {
        format.setTimeZone(TimeZone.getTimeZone("GMT"));
    }
}

static Date parseDate(CharSequence dateValue) {
    char c = dateValue.charAt(0);
    if (c >= '0' && c <= '9') {
        return new Date(Int.parse(dateValue.toString()));
    }
    for (DateHeaderParser parser : DateHeaderParser.values()) {
        try {
            Date result = parser.format.parse(dateValue.toString());
            if (result != Null) {
                return result;
            }
        } catch (Exception e) {
        }
    }
    return Null;
}
}