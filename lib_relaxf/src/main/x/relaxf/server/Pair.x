public class Pair {
Object a;
Object b;
construct (Object a, Object b) {
this.a = a;
this.b = b;
}

Boolean equals(Object o) {
if (this != o) {
if (o.is(Pair)) {
Pair p = o;
Boolean aEqual = Null == a ? Null == p.a : a.equals(p.a);
Boolean bEqual = Null == b ? Null == p.b : b.equals(p.b);
return aEqual && bEqual;
}
}
return False;
}
}