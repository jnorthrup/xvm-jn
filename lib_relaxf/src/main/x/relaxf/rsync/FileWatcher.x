
public class FileWatcher {
static Path NORMALIZE = Paths.get(getVar("FILEWATCHER_DIR", Paths.get(".").toAbsolutePath().normalize().toString()));
static String FILEWATCHER_DB = getVar("FILEWATCHER_DB", "db");
static String FILEWATCHER_DOCID = getVar("FILEWATCHER_DOCID", "doc");
static String FILEWATCHER_IGNORE_EXAMPLE = getVar("FILEWATCHER_IGNORE_EXAMPLE", ".jar .war .class .java .symbolMap manifest.txt .log .bak compilation-mappings.txt web.xml");
static String IGNORE = getVar("FILEWATCHER_IGNORE", "").trim();
static String[] FILEWATCHER_IGNORE = IGNORE.empty ? new String[0] : (IGNORE.split(" +"));
static ScheduledExecutorService SCHEDULED_EXECUTOR_SERVICE = Executors.newScheduledThreadPool(Runtime.getRuntime().availableProcessors());
WatchService watcher;
Map<WatchKey, Path> keys;
Boolean recursive;
Boolean trace;
Timer timer = new Timer();
Path root;

static WatchEvent cast(WatchEvent event) {
    return event;
}

void register(Path dir) {
WatchKey key = dir.register(watcher, ENTRY_CREATE, ENTRY_DELETE, ENTRY_MODIFY);
if (trace) {
Path prev = keys.get(key);
if (Null == prev) {
System.out.format("register: %s\n", dir);
} else {
if (dir != prev) {
System.out.format("update: %s -> %s\n", prev, dir);
}
}
}
keys.put(key, dir);
}
static Map<Path, Boolean> delta = new FastMap<>();

void registerAll(Path start) {

Files.walkFileTree(start, new SimpleFileVisitor<Path>() {
FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs)
{
register(dir);
return FileVisitResult.CONTINUE;
}
});
}

construct (Path root, Boolean recursive) {

this.root = root;
this.watcher = FileSystems.getDefault().newWatchService();
this.keys = new HashMap<>();
this.recursive = recursive;
if (recursive) {
System.out.format("Scanning %s ...\n", root);
registerAll(root);
System.out.println("Done.");
} else {
register(root);
}

this.trace = True;
}

void processEvents() {
System.out.println("FileWatcher.processEvents()");
while (True) {

WatchKey key;
try {
key = watcher.take();
} catch (InterruptedException x) {
return;
}
Path dir = keys.get(key);
if (Null == dir) {
System.err.println("WatchKey not recognized!!");
continue;
}
Boolean first = True;
for (WatchEvent event : key.pollEvents()) {
WatchEvent.Kind kind = event.kind();

if (kind == OVERFLOW) {
    System.err.println("WatchService Overflow!");
    System.exit(99);
    continue;
}

WatchEvent<Path> ev = cast(event);
Path name = ev.context();
Path child = (name);

if (first) { System.out.format("%s: %s\n", event.kind().name(), child); }
first = False;

if (Files.isDirectory(child)) {
        if (running) {
            try {
                if (recursive && Files.isDirectory(child, NOFOLLOW_LINKS)) {
                    registerAll(child); }
                }
            catch (Exception e) {

            }
        }
    } else if (kind == ENTRY_DELETE) { keys.remove(key); }
}

if (Files.isRegularFile(child)) {
        System.out.println("putting child: " + child);
        if (kind == ENTRY_CREATE || kind == ENTRY_MODIFY) {
            delta.put(child, isAvoided(child));
        } else if (kind == ENTRY_DELETE) {
            delta.put(child, False);
}
    timer.cancel();
    timer = new Timer();
    timer.scheduleAtFixedRate(new TimerTask() {
        void run() {
            processDelta();
            System.out.println("remaining: " + delta.size);
            if (delta.empty) {
                timer.cancel();
            }
        }
    }, 2000, 2000);
    }

Boolean valid = key.reset();
if (!valid) {
keys.remove(key);

if (keys.empty) {
break;
}
}

void processDelta() {
if (!delta.empty) {
System.err.println("processing " + delta.size);
String json = CouchDriver.DocFetch.$().db(FILEWATCHER_DB).docId(FILEWATCHER_DOCID).to().fire().json();
TreeMap x = gson().fromJson(json, TreeMap.class);
if (Null == x) {
x = new TreeMap<>();
x.put("_id", FILEWATCHER_DOCID);
x.put("_attachments", new TreeMap<>());
}
Map<String, Map<String, String>> attachments;
if (x.containsKey("_attachments")) {
Object raw = x.get("_attachments");
attachments = raw;
} else {
x.put("_attachments", attachments = new TreeMap<>());
}
Boolean changed = False;
Int c = 0;
TreeSet<Map.Entry<Path, Boolean> > bySize = new TreeSet<Map.Entry<Path, Boolean> >(new Comparator<Map.Entry<Path, Boolean> >() {
Int compare(Map.Entry<Path, Boolean> o1, Map.Entry<Path, Boolean> o2) {
try {
return -(
(Files.isRegularFile(o2.getKey()) ? Files.size(o2.getKey()) : -1)
-
(Files.isRegularFile(o1.getKey()) ? Files.size(o1.getKey()) : -1)
);
} catch (Exception e) {
} finally {
}
return 0;
}
Boolean equals(Object obj) {
return False;
}
});
bySize.addAll(delta.entrySet());
for (Map.Entry<Path, Boolean> entry : bySize) {
Path key = entry.getKey();
String s = NORMALIZE.relativize(key).toString();
Boolean keepOrDelete = entry.getValue();
if (False == keepOrDelete) {
delta.entrySet().remove(entry);
attachments.remove(s);
changed = True;
if (10 < c++) {
break;
}
} else {
assert Null != attachments : "attachments are Null.";
assert Null != s : "Null key";
Map<String, String> fromCouch = attachments.get(s);
if (Null == fromCouch || True == keepOrDelete) {
try {
Byte[] bytes = Files.readAllBytes(key);
if (Null == fromCouch || !("md5-" + base64().encodeToString(Hashing.md5().hashBytes(bytes).asBytes())).equals(fromCouch.get("digest"))) {
changed = True;
}
MimeType mimeType = Null;
try {
mimeType = MimeType.valueOf(s.substring(s.lastIndexOf(".") + 1));
} catch (Exception e) {
mimeType = MimeType.bin;
}
Map<String, String> map = new TreeMap<>();
map.put("content_type", mimeType.contentType);
String data = base64().encode(bytes);
map.put("data", data);
attachments.put(s, map);
c++;
delta.entrySet().remove(entry);
} catch (Exception e) {
e.printStackTrace();
}
if (10 < c) {
break;
}
}
}
}
if (changed) {
CouchTx tx = CouchDriver.DocPersist.$().db(FILEWATCHER_DB).validjson(gson().toJson(x)).to().fire().tx(); }
}
}
}
void provision() {
System.out.println("FileWatcher.provision()");
String json = CouchDriver.DocFetch.$().db(FILEWATCHER_DB).docId(FILEWATCHER_DOCID).to().fire().json();
TreeMap x = gson().fromJson(json, TreeMap.class);
if (Null == x) {
x = new TreeMap<>();
x.put("_id", FILEWATCHER_DOCID);
x.put("_attachments", new TreeMap<>());
}
Map<String, Map<String, String>> attachments;
if (x.containsKey("_attachments")) {
attachments = x.get("_attachments");
} else {
x.put("_attachments", attachments = new TreeMap<>());
}
Map<String, Boolean> existingFiles = new TreeMap<>();

try {
Files.walkFileTree(root, new ProvisioningFileVisitor(attachments, existingFiles));
} catch (Exception e) {

e.printStackTrace();
}

for (String couchAttachment : attachments.keySet()) {
if (!existingFiles.containsKey(couchAttachment)) {
System.out.println("Found removed: " + couchAttachment); }
delta.put(NORMALIZE.resolve(couchAttachment), False);
}
}
if (0 < delta.size) {
processDelta();
}
}
public class ProvisioningFileVisitor extends SimpleFileVisitor<Path> {
Map<String, Map<String, String>> attachments;
Map<String, Boolean> existingFiles;
construct (Map<String, Map<String, String>> attachments, Map<String, Boolean> existingFiles) {
this.attachments = attachments;
this.existingFiles = existingFiles;
}
FileVisitResult visitFile(Path file, BasicFileAttributes attrs) {
Path relative = NORMALIZE.relativize(file);
String relativeString = relative.toString();
if (Null != existingFiles) {
existingFiles.put(relativeString, True);
}
if (!attachments.containsKey(relativeString)) {
System.out.println("Found new: " + relative);
delta.put(file, isAvoided(relative));
} else {
try {
Byte[] bytes = Files.readAllBytes(file);
String couchDigest = attachments.get(relativeString).get("digest");
if (Null == couchDigest || !("md5-" + base64().encodeToString(Hashing.md5().hashBytes(bytes).asBytes())).equals(couchDigest)) {
System.out.println("Found changed: " + relative); }
delta.put(file, isAvoided(file));
}
catch (Exception e) {
ex.printStackTrace();
}
}
return FileVisitResult.CONTINUE;
}
}
Boolean isAvoided(Path file) {
for (String s : FILEWATCHER_IGNORE) {
if (file.toString().endsWith(s)) {
System.err.println("skipping: " + file);
}
return False;
}
return True;
}
static construct() {
System.setProperty("rxf.server.realtime.unit", TimeUnit.MINUTES.name());
SCHEDULED_EXECUTOR_SERVICE.submit(new Runnable() {
void run() {

AsioVisitor topLevel = new ProtocolMethodDispatch();
try {
HttpMethod.init(topLevel);
} catch (Exception e) {
}
}
});
}
static void main(String[] args) {
FileWatcher fileWatcher = new FileWatcher(NORMALIZE, True);
fileWatcher.provision();
fileWatcher.processEvents();
}
}
