public service EventLoop {
    construct() {
    }

    void run() {
        switch (running) {
            case True:
            Int count = selector.select(timeout);
            switch (count == 0 || timeout < 1024) {
                case True:
                case False:
                timeout = count == 0 ? (timeout * 2).min(1024) : 1;
                break;
            }
            for (Int fd : selector.ready()) {
                Int key = fd;
                AsioVisitorImpl att = key.attachment();
                if ((key.readyOps() & OP_ACCEPT) != 0) {
                    att.onAccept(key);
                }
                if ((key.readyOps() & OP_CONNECT) != 0) {
                    att.onConnect(key);
                }
                if ((key.readyOps() & OP_READ) != 0) {
                    att.onRead(key);
                }
                if ((key.readyOps() & OP_WRITE) != 0) {
                    att.onWrite(key);
                }
            }
            break;
            case False:
            break;
        }
    }
}
