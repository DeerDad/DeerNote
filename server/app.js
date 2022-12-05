var koa = require("koa");
var app = new koa();
var logger = require("./utils/log");
const config = require("config");
const session = require("koa-session");
const passport = require("koa-passport");

// error handle
catchError = require("./middlewares/catch_error").catchError;
app.use(catchError);

// cros
const cors = require("@koa/cors");
const cros_ip = config.get("network.cros_ip");
const cros_port = config.get("network.cros_port");
app.use(cors({ credentials: true, origin: [ `http://${cros_ip}:${cros_port}`] }));
logger.log(`cros origin: http://${cros_ip}:${cros_port}`)

// mongodb
let mongoose = require("mongoose");
const db_url = config.get("db_config.db_url");
const user = config.get("db_config.user");
const pass = config.get("db_config.pass");
mongoose.connect(
    db_url,
    {
        serverSelectionTimeoutMS: 5000,
        authSource: "admin",
        user: user,
        pass: pass,
    },
    function (err, db) {
        if (!err) {
            logger.info(`connect ${db_url} success`);
        } else {
            logger.error(`${err}`);
        }
    }
);

// session
app.keys = ["super-secret-key"];
app.use(session({ sameSite: "lax" }, app));

// body parser
const bodyparser = require("koa-bodyparser");
app.use(bodyparser());

// auth
require("./utils/auth");
app.use(passport.initialize());
app.use(passport.session());

// routes
const fs = require("fs");
const route = require("koa-route");

app.use(
    route.get("/", function (ctx) {
        ctx.type = "html";
        ctx.body = fs.readFileSync("views/index.html", "utf8");
    })
);

// users
const authentication = require("./middlewares/authentication");
const compose = require("koa-compose");

var user_ops = require("./apis/user_ops");
app.use(
    route.get("/login", function (ctx) {
        ctx.type = "html";
        ctx.body = fs.readFileSync("views/login.html", "utf8");
    })
);
app.use(route.post("/login", user_ops.user_login));

app.use(
    route.get("/logout", function (ctx) {
        ctx.type = "html";
        ctx.body = fs.readFileSync("views/logout.html", "utf8");
    })
);
app.use(route.post("/logout", compose([authentication, user_ops.user_logout])));

app.use(
    route.get("/register", function (ctx) {
        ctx.type = "html";
        ctx.body = fs.readFileSync("views/register.html", "utf8");
    })
);
app.use(route.post("/register", user_ops.user_register));

app.use(
    route.get("/deleteUser", function (ctx) {
        ctx.type = "html";
        ctx.body = fs.readFileSync("views/deleteUser.html", "utf8");
    })
);
app.use(
    route.post("/deleteUser", compose([authentication, user_ops.user_delete]))
);

app.use(
    route.get("/modifyUserNickname", function (ctx) {
        ctx.type = "html";
        ctx.body = fs.readFileSync("views/modifyUserNickname.html", "utf8");
    })
);
app.use(
    route.post(
        "/modifyUserNickname",
        compose([authentication, user_ops.user_modify_nickname])
    )
);

app.use(
    route.get("/modifyUserHeadpic", function (ctx) {
        ctx.type = "html";
        ctx.body = fs.readFileSync("views/modifyUserHeadpic.html", "utf8");
    })
);
app.use(
    route.post(
        "/modifyUserHeadpic",
        compose([authentication, user_ops.user_modify_headpic])
    )
);

//pages
var page_ops = require("./apis/page_ops");
app.use(
    route.get("/getUserFolder", function (ctx) {
        ctx.type = "html";
        ctx.body = fs.readFileSync("views/getUserFolder.html", "utf8");
    })
);
app.use(
    route.post(
        "/getUserFolder",
        compose([authentication, page_ops.get_user_folder])
    )
);

app.use(
    route.post(
        "/updateUserFolder",
        compose([authentication, page_ops.update_user_folder])
    )
);

app.use(
    route.post(
        "/deleteUserPages",
        compose([authentication, page_ops.delete_user_pages])
    )
);

app.use(
    route.post(
        "/getUserPage",
        compose([authentication, page_ops.get_user_page])
    )
);

app.use(
    route.post(
        "/updateUserPages",
        compose([authentication, page_ops.update_user_pages])
    )
);

const http_port = config.get("network.http_port");
app.startup = function () {
    return app.listen(http_port);
};

module.exports = app;
