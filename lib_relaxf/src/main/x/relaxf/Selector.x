/**
 * Native NIO selector. Provides epoll/kqueue-based event notification.
 * The select() call runs inline on the calling thread with no service boundary.
 */
public service Selector {
    Int select(Int timeout);
}
