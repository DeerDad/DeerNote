const logger = require("../utils/log");
var PROTO_PATH = __dirname + "/../../protos/p01.proto";
const protobuf = require("protobufjs");
const serializer = require("proto3-json-serializer");
const root = protobuf.loadSync([PROTO_PATH]);

const metaMap = {};

fromJson = function (meta, json) {
    if (!(meta in metaMap)) {
        metaMap[meta] = root.lookupType(`p01.${meta}`);
    }
    
    const message = serializer.fromProto3JSON(metaMap[meta], JSON.parse(json));
    return message;
};

fromObject = function (meta, obj) {
    if (!(meta in metaMap)) {
        metaMap[meta] = root.lookupType(`p01.${meta}`);
    }

    const message = serializer.fromProto3JSON(metaMap[meta], obj);
    return message;
};

toJson = function (message) {
    const json = JSON.stringify(serializer.toProto3JSON(message));
    return json;
};

fromCtx = function (ctx, meta) {
    var message_body = lookup(ctx.request.body, "message");
    return fromJson(meta, message_body);
};

module.exports = {
    fromJson: fromJson,
    fromObject: fromObject,
    fromCtx: fromCtx,
    toJson: toJson,
};
