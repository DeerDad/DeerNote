const { HttpError } = require("koa");
const User = require("../models/user");
const Cdkey = require("../models/cdkey");
lookup = require("../utils/lookup").lookup;
const passport = require("koa-passport");
const { HttpException, ErrorCodes } = require("../middlewares/catch_error");
const { response } = require("../utils/response");
const logger = require("../utils/log");
const { lookupuser } = require("../utils/lookup");
const pb = require("../utils/pb");
require("../utils/auth");

let user_register = async function (ctx, next) {
    var request = pb.fromCtx(ctx, "RegisterRequest");
    var account = request.account;
    var password = request.password;
    var cdkey = request.cdkey;

    if (account == null || password == null || cdkey == null) {
        throw new HttpException(ErrorCodes.ParamError);
    }

    data = await User.findOne({ account: account });
    if (data != null) {
        throw new HttpException(ErrorCodes.UserAlreadyExists);
    }

    cdkey_date = await Cdkey.findOne({key: cdkey});
    if (cdkey_date == null)
    {
        throw new HttpException(ErrorCodes.RegisterNeedKey);
    }

    await Cdkey.deleteOne({key: cdkey});

    userProfile = {
        account: account,
        password: password,
        nickname: account,
    };

    var message = pb.fromObject("UserProfile", userProfile);

    new_user = new User({
        account: account,
        message: pb.toJson(message),
    });

    await new_user.save();
    
    ctx.request.body.account = account;
    ctx.request.body.password = password;

    await passport.authenticate("local", function (err, data) {
        if (err) {
            throw new HttpException(ErrorCodes.DBQueryError);
        }

        if (data instanceof Object == false) {
            throw new HttpException(ErrorCodes.UserDoesnotExists);
        }

        var message = pb.fromJson("UserProfile", data.message);
        if (message.password != password) {
            throw new HttpException(ErrorCodes.WrongPassword);
        }

        ctx.login(data);
        response(ctx, message);
    })(ctx, next);
};

let user_delete = async function (ctx, next) {
    var user_name = lookup(ctx.request.body, "username");
    if (user_name == null) {
        throw new HttpException(ErrorCodes.ParamError);
    }

    await User.deleteOne({ user_name: user_name });
    response(ctx, {});
};

let user_login = async function (ctx, next) {
    var request = pb.fromCtx(ctx, "LoginRequest");
    var account = request.account;
    var password = request.password;
    ctx.request.body.account = account;
    ctx.request.body.password = password;

    await passport.authenticate("local", function (err, data) {
        if (err) {
            throw new HttpException(ErrorCodes.DBQueryError);
        }

        if (data instanceof Object == false) {
            throw new HttpException(ErrorCodes.UserDoesnotExists);
        }

        var message = pb.fromJson("UserProfile", data.message);
        if (message.password != password) {
            throw new HttpException(ErrorCodes.WrongPassword);
        }

        ctx.login(data);
        response(ctx, message);
    })(ctx, next);
};

let user_modify_nickname = async function (ctx, next) {
    var request = pb.fromCtx(ctx, "ModifyNicknameRequest");
    var account = request.account;
    var nickname = request.nickname;

    if (account == null || nickname == null) {
        throw new HttpException(ErrorCodes.ParamError);
    }

    var authed_account = lookupuser(ctx);
    if (account != authed_account) {
        throw new HttpException(ErrorCodes.UserDoesnotMatch);
    }

    var data = await User.findOne({ account: account });
    if (data == null) {
        throw new HttpException(ErrorCodes.UserDoesnotExists);
    }

    var message = pb.fromJson("UserProfile", data.message);
    message.nickname = nickname;
    data.message = pb.toJson(message);

    await data.save();
    response(ctx, message);
};

let user_modify_headpic = async function (ctx, next) {
    var user_name = lookup(ctx.request.body, "username");
    var headpic = lookup(ctx.request.body, "headpic");
    if (user_name == null || headpic == null) {
        throw new HttpException(ErrorCodes.ParamError);
    }

    var authed_user_name = lookupuser(ctx);
    if (user_name != authed_user_name) {
        throw new HttpException(ErrorCodes.UserDoesnotMatch);
    }

    var data = await User.findOne({ user_name: user_name });
    if (data == null) {
        throw new HttpException(ErrorCodes.UserDoesnotExists);
    }

    data.user_headpic = headpic;

    await data.save();
    response(ctx, data);
};

let user_logout = async function (ctx, next) {
    var request = pb.fromCtx(ctx, "LogoutRequest");
    var account = request.account;

    var authed_account = lookupuser(ctx);
    if (account != authed_account) {
        throw new HttpException(ErrorCodes.UserDoesnotMatch);
    }

    ctx.logout();
    var message = pb.fromObject("EmptyMessage", {});
    response(ctx, message);
};

module.exports = {
    user_register: user_register,
    user_login: user_login,
    user_logout: user_logout,
    user_delete: user_delete,
    user_modify_nickname: user_modify_nickname,
    user_modify_headpic: user_modify_headpic,
};
