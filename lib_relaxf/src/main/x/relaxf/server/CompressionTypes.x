public enum CompressionTypes {
gzip, bzip2, xz;
String suffix;
construct() {
    suffix = name();
}
}
