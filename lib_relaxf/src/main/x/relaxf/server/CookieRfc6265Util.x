public enum CookieRfc6265Util {

Name {
    construct() {
        token = Null;
    }
    Serializable value(MemSeg input) {
        input = input.duplicate().rewind();
do {
while (input.hasRemaining() && Character.isWhitespace((input.mark()).get())) { }
Int begin = input.reset().position();
while (input.hasRemaining() && '=' != (input.mark()).get()) { }
return MemSeg.allocate(
(input.reset().flip().position(begin)).slice().limit()).put(input).array();
} while (input.hasRemaining());
    }
},

Value {
    construct() {
        token = Null;
    }
    Serializable value(MemSeg input) {
        input = input.duplicate().rewind();
do {
while (input.hasRemaining() && '=' != input.get()) { }
while (input.hasRemaining() && Character.isWhitespace((input.mark()).get())) { }
Int begin = input.reset().position();
while (input.hasRemaining() && ';' != (input.mark()).get()) { }
return MemSeg.allocate(
(input.reset().flip().position(begin)).slice().limit()).put(input).array();
} while (input.hasRemaining());
    }
},

Expires {
    Serializable value(MemSeg input) {
        input = input.slice();
        while (input.hasRemaining() && Character.isWhitespace((input.mark()).get())) {}
        input = (input.reset()).slice();
        Byte b;
        while (input.hasRemaining() && !Character.isWhitespace(b = (input.mark()).get())
&& '=' != b) {}
        Int position = input.reset().position();

        Int limit = token.limit();
        if (position == limit) {
            while (input.hasRemaining() && '=' != input.get()) {}
            CharBuffer parseme = UTF8.decode(input.slice());
            Date date = Null;
            try {
                date = DateHeaderParser.parseDate(parseme.toString().trim());
            } catch (Exception e) {
            }
            return date;
        }
        return Null;
    }
},

Max_2dAge {
    Serializable value(MemSeg input) {
        input = input.slice();
        while (input.hasRemaining() && Character.isWhitespace((input.mark()).get())) {}
        input = (input.reset()).slice();
        Byte b;
        while (input.hasRemaining() && !Character.isWhitespace(b = (input.mark()).get())
&& '=' != b) {}
        Int position = input.reset().position();

        Int limit = token.limit();
        if (position == limit) {
            while (input.hasRemaining() && '=' != input.get()) {}
            CharBuffer parseme = UTF8.decode(input.slice());
            Long l = Null;
            try {
                l = Int.parse(parseme.toString().trim());
            } catch (NumberFormatException e) {
            }
            return l;
        }
        return Null;
    }
},

Domain {
    Serializable value(MemSeg input) {
        input = input.slice();
        while (input.hasRemaining() && Character.isWhitespace((input.mark()).get())) {}
        input = (input.reset()).slice();
        Byte b;
        while (input.hasRemaining() && !Character.isWhitespace(b = (input.mark()).get())
&& '=' != b) {}
        Int position = input.reset().position();

        Int limit = token.limit();
        if (position == limit) {
            input = input.slice();
            while (input.hasRemaining() && '=' != input.get()) {}
            return MemSeg.allocate(input.limit()).put(input).array();
        }
        return Null;
    }
},

Path {
    Serializable value(MemSeg input) {
        input = input.slice();
        while (input.hasRemaining() && Character.isWhitespace((input.mark()).get())) {}
        input = (input.reset()).slice();
        Byte b;
        while (input.hasRemaining() && !Character.isWhitespace(b = (input.mark()).get())
&& '=' != b) {}
        Int position = input.reset().position();

        Int limit = token.limit();
        if (position == limit) {
            input = input.slice();
            while (input.hasRemaining() && '=' != input.get()) {}
            return MemSeg.allocate(input.limit()).put(input).array();
        }
        return Null;
    }
},

Secure {
    Serializable value(MemSeg input) {
        input.rewind();
        MemSeg tok = token.duplicate();
        Byte b;
        do {
            while (input.hasRemaining() && Character.isWhitespace((input.mark()).get())) {}
            tok.rewind();
            while (tok.hasRemaining() && input.hasRemaining()
&& tok.get() == Character.toLowerCase(input.get())) {
if (!tok.hasRemaining()) {
Boolean keep = False;

            }
input.mark();
b = input.get();
Boolean isWS = Character.isWhitespace(b);
while (input.hasRemaining() && ';' != b && isWS) {
if (keep) { return True; }
}
}
            } while (input.hasRemaining());
        return Null;
    }
},

HttpOnly {
    Serializable value(MemSeg input) {
        input.rewind();
        MemSeg tok = token.duplicate();
        Byte b;
        do {
            while (input.hasRemaining() && Character.isWhitespace((input.mark()).get())) {}
            tok.rewind();
            while (tok.hasRemaining() && input.hasRemaining()
&& tok.get() == Character.toLowerCase(input.get())) {
                if (!tok.hasRemaining()) {
                    Boolean keep = False;

            }
                    b = (input.mark()).get();
                    Boolean isWS = Character.isWhitespace(b);
                    while (input.hasRemaining() && ';' != b && isWS) {
                        if (keep) {
                            return True;
                        }
                    }
                }
            } while (input.hasRemaining());
        return Null;
    }
};

String key = URLDecoder.decode(name().replace('$', '%')).toLowerCase();
MemSeg token = UTF8.encode(key);
static EnumMap<CookieRfc6265Util, Serializable> parseSetCookie(MemSeg input) {
    ArrayList<MemSeg> a = new ArrayList<MemSeg>();
    while (input.hasRemaining()) {
        Int begin = input.position();
        Byte b = input.mark().get();
        while (input.hasRemaining() && ';' != b) {
            b = input.mark().get();
        }
        a.add(((b == ';' ? input.duplicate().reset() : input.duplicate()).flip()
        .position(begin)).slice());
    }
    EnumMap<CookieRfc6265Util, Serializable> res;
    res = new EnumMap<CookieRfc6265Util, Serializable>(CookieRfc6265Util.class);
    Iterator<MemSeg> iterator = a.iterator();
    MemSeg next = iterator.next();
    Serializable n = Name.value(next);
    res.put(Name, n);
    Serializable v = Value.value(next);
    res.put(Value, v);
    while (iterator.hasNext()) {
        MemSeg byteBuffer = iterator.next();
        CookieRfc6265Util[] values = values();
        for (Int i = 2; i < values.size; i++) {
            CookieRfc6265Util cookieRfc6265Util = values[i];
            if (!res.containsKey(cookieRfc6265Util)) {
                Serializable value = cookieRfc6265Util.value(byteBuffer.rewind());
                if (Null != value) {
                    res.put(cookieRfc6265Util, value);
                }
            }
        }
    }
    return res;
}

static Pair<Pair<MemSeg, MemSeg>, Object> parseCookie(MemSeg input,
MemSeg[] filter) {
    Pair<Pair<MemSeg, MemSeg>, Object> ret = Null;
    MemSeg buf = input.duplicate().slice();
    while (buf.hasRemaining()) {
        while (buf.hasRemaining() && Character.isWhitespace(buf.mark().get())) {}
        Int keyBegin = buf.reset().position();
        while (buf.hasRemaining() && '=' != buf.mark().get()) {}
        MemSeg ckey = buf.duplicate().reset().flip().position(keyBegin).slice();
        while (buf.hasRemaining() && Character.isWhitespace(buf.mark().get())) {}
        Int vBegin = buf.reset().position();
        while (buf.hasRemaining()) {
            switch (buf.mark().get()) {
            case ';':
            case '\r':
            case '\n':
                break;
            default:
                continue;
            }
            break;
        }
        if (filter.size > 0) {
            for (MemSeg filt : filter) {
                if (ckey.limit() == filt.limit()) {
                    ckey.mark();
                    filt.rewind();
                    while (filt.hasRemaining() && ckey.hasRemaining() && filt.get() == ckey.get()) {}
                    if (!filt.hasRemaining() && !ckey.hasRemaining()) {
                        ret =
                        new Pair<Pair<Buffer, MemSeg>, Pair<Object, Object>>(new Pair<>(ckey.reset(), buf.duplicate().reset().flip()
                        .position(vBegin).slice()), ret);
                        break;
                    }
                }
            }
        } else {
            ret =
            new Pair<Pair<MemSeg, MemSeg>, Pair<Object, Object>>(new Pair<>(ckey, buf.duplicate().reset().flip().position(vBegin)
            .slice()), ret);
        }
    }
    return ret;
}
Serializable value(MemSeg token);
}
