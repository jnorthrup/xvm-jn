public class ActionBuilder {
static String[] HEADER_INTEREST =
Rfc822HeaderState.staticHeaderStrings(ETag, Content_2dLength);
AtomicReference<Rfc822HeaderState> state = new AtomicReference<Rfc822HeaderState>();
Int key;
static ThreadLocal<ActionBuilder> currentAction =
new InheritableThreadLocal<ActionBuilder>();
construct() {
currentAction.set(this);
}
TerminalBuilder fire();

String toString() {
return "ActionBuilder{" + "state=" + state + ", key=" + key + '}';
}
Rfc822HeaderState state() {
Rfc822HeaderState ret = this.state.get();
if (Null == ret) {
state.set(ret = new Rfc822HeaderState(HEADER_INTEREST));
}
return ret;
}
Int key() {
return this.key;
}
ActionBuilder state(Rfc822HeaderState state) {
this.state.set(state);
return this;
}
ActionBuilder key(Int key) {
this.key = key;
return this;
}
static ActionBuilder get() {
if (currentAction.get() == Null) {
currentAction.set(new ActionBuilder() {

TerminalBuilder fire() {
throw new AbstractMethodError(
"This is a ActionBuilder with no DbKeysBuilder and therefore now Terminal");
}
});
}
return currentAction.get();
}
}