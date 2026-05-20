public const DbKeys {
    enum etype {
        opaque,
        db,
        docId,
        rev,
        attachname,
        designDocId,
        view,
        validjson,
        mimetype,
        mimetypeEnum,
        blob,
        type,
        keyType
    }

    etype[] value();
    etype[] optional();
}
