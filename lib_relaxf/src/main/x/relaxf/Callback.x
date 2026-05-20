/**
 * Pre-registered continuation callback. Fires inline on the calling thread.
 * No fiber, no service boundary, no allocation.
 */
public const Callback(Store store, Int id) {
    void invoke();
}
