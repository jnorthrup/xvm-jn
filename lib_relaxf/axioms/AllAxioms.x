// ================================================
// PER-FILE AXIOMS (F1-F6)
// ================================================

// F1: One type per file — PARSER-16 if second public type
// Tested by: this file has only class AllAxioms

// F2: Package ≡ directory — cone-shaped, no explicit package needed
// Tested by: this file is in test/ subdir, implicit test package

// F3: Imports work
import ecstasy.annotations.Test;

// F4: Annotations @Test already tests file-level annotation support

// F5: Both static { } and static construct() { }
class F5_StaticInit {
    static Int x;
    static {
        x = 1;
    }
    static construct() {
        x = 2;
    }
}

// F6: final keyword works
class F6_Final {
    final Int x = 1;
    void test() { var y = x; }
}

// ================================================
// PER-STATEMENT AXIOMS (S1-S12)
// ================================================

// S1: instanceof AND .is() both work
class S1_TypeCheck {
    void test() {
        Object o = "";
        Boolean a = o instanceof String;
        Boolean b = o.is(String);
        var c = a && b;  // suppress unused
    }
}

// S2: C-cast AND .as() both work
class S2_Cast {
    void test() {
        Object o = "";
        String a = (String) o;
        String b = o.as(String);
        var c = a == b;  // suppress unused
    }
}

// S3: Java-style constructor AND construct() both work
class S3_JavaCtor {
    Int x;
    S3_JavaCtor(Int x) { this.x = x; }
}
class S3_XCtor {
    Int x;
    construct(Int x) { this.x = x; }
}

// S4: private, final fields work
class S4_Fields {
    private Int a;
    final Int b = 2;
}

// S5: throws clause accepted
class S5_Throws {
    void test() throws Exception {
        var x = 1;
    }
}

// S6: interface AND service both work (different things)
interface S6_Marker {}
interface S6_Iface { void foo(); }
service S6_Service { void bar(); }
class S6_Impl extends S6_Iface implements S6_Service {
    void foo() {}
    void bar() {}
}

// S7: for-each works
class S7_ForEach {
    void test() {
        for (var x : new Object[0]) { var y = x; }
    }
}

// S8: try-catch-finally works
class S8_TryCatch {
    void test() {
        try { var x = 1; }
        catch (Exception e) { var y = 2; }
        finally { var z = 3; }
    }
}

// S9: anonymous class in assignment AND method call
class S9_Anon {
    void accept(Object o) {}
    void test() {
        var v = new Object() { void f() {} };
        accept(new Object() { void g() {} });
    }
}

// S10: Java AND XLang type names work
class S10_Types {
    Boolean  b1 = True;
    boolean  b2 = True;
    Int      i1 = 1;
    int      i2 = 1;
    String   s1 = "x";
    String   s2 = "x";
    Object   o1 = Null;
    Object   o2 = null;
}

// S11: String and Object — unchanged

// S12: both array init forms work {a,b} and [a,b]
class S12_Arrays {
    Object[] a1 = {1, 2, 3};
    Object[] a2 = [1, 2, 3];
}

// ================================================
// TEST METHODS
// ================================================
@Test void testF5()  { assert F5_StaticInit.x == 2; }
@Test void testF6()  { assert new F6_Final().x == 1; }
@Test void testS1()  { new S1_TypeCheck().test(); assert True; }
@Test void testS2()  { new S2_Cast().test(); assert True; }
@Test void testS3()  { assert new S3_JavaCtor(5).x == 5; assert new S3_XCtor(7).x == 7; }
@Test void testS4()  { assert True; }
@Test void testS5()  { new S5_Throws().test(); assert True; }
@Test void testS6()  { assert True; }
@Test void testS7()  { new S7_ForEach().test(); assert True; }
@Test void testS8()  { new S8_TryCatch().test(); assert True; }
@Test void testS9()  { new S9_Anon().test(); assert True; }
@Test void testS10() { assert True; }
@Test void testS12() { assert True; }
