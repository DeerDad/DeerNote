const logger = require("../utils/log");
const { HttpException, ErrorCodes } = require("./catch_error");

authentication = async function (ctx, next) {
    if (ctx.isAuthenticated()) {
        await next();
    } else {
        throw new HttpException(ErrorCodes.UnAuth);
    }
};

module.exports = authentication;
