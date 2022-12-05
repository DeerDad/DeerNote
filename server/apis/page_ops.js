const { HttpException, ErrorCodes } = require("../middlewares/catch_error");
const { response } = require("../utils/response");
const logger = require("../utils/log");
const pb = require("../utils/pb");
const { lookupuser } = require("../utils/lookup");
const Folder = require("../models/folder");
const Page = require("../models/page");

let get_user_folder = async function (ctx, next) {
    var request = pb.fromCtx(ctx, "GetUserFolderRequest");
    var account = request.account;

    if (account == null) {
        throw new HttpException(ErrorCodes.ParamError);
    }

    var authed_account = lookupuser(ctx);
    if (account != authed_account) {
        throw new HttpException(ErrorCodes.UserDoesnotMatch);
    }

    var data = await Folder.findOne({ account: account });
    var message = null;
    if (data == null) {
        userFolder = {
            account: account,
            rootPage: {
                uuid: "",
                name: "",
                subPages: [],
            },
        };

        message = pb.fromObject("UserFolder", userFolder);

        new_folder = new Folder({
            account: account,
            message: pb.toJson(message),
        });

        await new_folder.save();
    } else {
        message = pb.fromJson("UserFolder", data.message);
    }

    response(ctx, message);
};

let update_user_folder = async function (ctx, next) {
    var request = pb.fromCtx(ctx, "UpdateUserFolderRequest");
    var user_folder = request.userFolder;

    if (user_folder == null) {
        throw new HttpException(ErrorCodes.ParamError);
    }

    var authed_account = lookupuser(ctx);
    if (user_folder.account == null || user_folder.account != authed_account) {
        throw new HttpException(ErrorCodes.UserDoesnotMatch);
    }

    replace_folder = {
        message: pb.toJson(user_folder),
    };

    await Folder.updateOne({ account: user_folder.account }, replace_folder);

    var message = pb.fromObject("EmptyMessage", {});
    response(ctx, message);
};

let delete_user_pages = async function (ctx, next) {
    var request = pb.fromCtx(ctx, "DeletePageRequest");
    var pages = request.pages;

    if (pages == null) {
        throw new HttpException(ErrorCodes.ParamError);
    }

    var authed_account = lookupuser(ctx);
    if (request.account == null || request.account != authed_account) {
        throw new HttpException(ErrorCodes.UserDoesnotMatch);
    }

    await Page.deleteMany({ uuid: {$in:pages} });

    var message = pb.fromObject("EmptyMessage", {});
    response(ctx, message);
};

let get_user_page = async function (ctx, next) {
    var request = pb.fromCtx(ctx, "GetUserPageRequest");
    var account = request.account;
    var uuid = request.uuid;

    if (uuid == null) {
        throw new HttpException(ErrorCodes.ParamError);
    }

    var authed_account = lookupuser(ctx);
    if (account == null || account!= authed_account) {
        throw new HttpException(ErrorCodes.UserDoesnotMatch);
    }
    
    var data = await Page.findOne({ uuid: uuid });
    var message = null;
    if (data == null) {
        pageDetail = {
            account: account,
            uuid: uuid,
            content: "",
        };

        message = pb.fromObject("PageDetail", pageDetail);

        new_page_detail = new Page({
            uuid: uuid,
            message: pb.toJson(message),
        });

        await new_page_detail.save();
    } else {
        message = pb.fromJson("PageDetail", data.message);

        if (message.account != authed_account)
        {
            throw new HttpException(ErrorCodes.UserDoesnotMatch);
        }
    }

    response(ctx, message);
};

let update_user_pages = async function (ctx, next) {
    var request = pb.fromCtx(ctx, "UpdatePageRequest");
    var pageDetails = request.pageDetails;

    if (pageDetails == null) {
        throw new HttpException(ErrorCodes.ParamError);
    }

    var authed_account = lookupuser(ctx);
    if (request.account == null || request.account != authed_account) {
        throw new HttpException(ErrorCodes.UserDoesnotMatch);
    }

    pageDetails.forEach(async function(value, index, array) {
        var data = await Page.findOne({uuid: value.uuid});
        if (value.account != authed_account)
        {
            logger.debug(`account not match ${value.account} ${authed_account}`);
            return;
        }

        if (data == null)
        {
            logger.debug(`find page ${value.uuid} null`);
            return;
        }
        
        exist_page = pb.fromJson("PageDetail", data.message);
        if (exist_page.uuid != value.uuid || exist_page.account != authed_account)
        {
            logger.debug(`exist_page ${exist_page.uuid}/${exist_page.account} =>  ${value.uuid}/${authed_account}`);
            return;
        }

        replace_page = {
            message: pb.toJson(value),
        };

        await Page.updateOne({ uuid: value.uuid }, replace_page);
    });

    var message = pb.fromObject("EmptyMessage", {});
    response(ctx, message);
};

module.exports = {
    get_user_folder: get_user_folder,
    update_user_folder: update_user_folder,
    delete_user_pages: delete_user_pages,
    get_user_page: get_user_page,
    update_user_pages: update_user_pages,
};
