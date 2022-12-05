const passport = require("koa-passport");
const User = require("../models/user");
const logger = require("./log");

passport.serializeUser(function (user, done) {
    done(null, { account: user.account, _id: user._id });
});

passport.deserializeUser(function (user, done) {
    User.findById(user._id, done);
});

const LocalStrategy = require("passport-local").Strategy;
passport.use(
    new LocalStrategy(
        { usernameField: "account", passwordField: "password" },
        function (account, password, done) {
            User.findOne({ account: account }, function (err, data) {
                done(err, data);
            });
        }
    )
);
