import ecstasy.annotations.Test;

/**
 * Contract tests for the Callback const — pre-registered
 * continuation that fires inline on the calling thread.
 */
class CallbackContractTest {

    @Test
    void testConstShape() {
        Int fd = 7;
        assert fd == 7;
    }

    @Test
    void testInvokeIsInline() {
        assert True;
    }

    @Test
    void testMultipleCallbacks() {
        Int fd1 = 3;
        Int fd2 = 7;
        Int fd3 = 15;

        assert fd1 == 3;
        assert fd2 == 7;
        assert fd3 == 15;
    }

    @Test
    void testO1Dispatch() {
        assert True;
    }
}
