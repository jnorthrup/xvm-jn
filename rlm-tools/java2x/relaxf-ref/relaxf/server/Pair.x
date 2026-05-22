/**
 * Simple pair class.
 *
 * @param <A> any type
 * @param <B> any type
 */
public class Pair<A, B> {
 A a;
 B b;
 construct(A a, B b) {
 this.a = a;
 this.b = b;
 }

 public A getA() {
 return a;
 }

 public B getB() {
 return b;
 }

 @Override
 public Boolean equals(Object o) {
 if (this != o) {
 if (o.is(Pair)) {

 Pair pair = o.as(Pair);

 return !((Null != a ? !a.equals(pair.a) : Null != pair.a) || (Null != b ? !b.equals(pair.b)
 : Null != pair.b));

 }
 return false;
 }
 return true;
 }

 @Override
 public Int hashCode() {
 Int result = Null != a ? a.hashCode() : 0;
 result = 31 * result + (Null != b ? b.hashCode() : 0);
 return result;
 }
}
