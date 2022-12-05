const logger = require("./log");
const pb = require("./pb");

exports.response = function (ctx, message) {
  ctx.response.status = 200;
  ctx.response.body = pb.toJson(message);
};
