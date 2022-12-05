const supertest = require("supertest");
const chai = require("chai");
const app = require("../app");
const logger = require("../utils/log");

const expect = chai.expect;

let server = app.startup();

const request = supertest(server);
const PB = require("../utils/pb");

describe("test http", () => {
    var Cookies;

    it("[POST]register", (done) => {
        var message = {
            account: "test",
            password: "test",
        };
        request
            .post("/register")
            .set("Connection", "keep alive")
            .set("Content-Type", "application/json")
            .type("form")
            .send({
                message: PB.toJson(PB.fromObject("RegisterRequest", message)),
            })
            .end((err, res) => {
                expect(res.status).to.be.oneOf([200, 605], res.text);
                done();
            });
    });

    it("[POST]login", (done) => {
        var message = {
            account: "test",
            password: "test",
        };
        request
            .post("/login")
            .set("Connection", "keep alive")
            .set("Content-Type", "application/json")
            .type("form")
            .send({
                message: PB.toJson(PB.fromObject("LoginRequest", message)),
            })
            .end((err, res) => {
                expect(res.status).to.equal(200, res.text);
                Cookies = res.headers["set-cookie"];
                done();
            });
    });

    it("[POST]modifyUserNickname", (done) => {
        var message = {
            account: "test",
            nickname: "abc",
        };
        request
            .post("/modifyUserNickname")
            .set("Cookie", Cookies)
            .set("Connection", "keep alive")
            .set("Content-Type", "application/json")
            .type("form")
            .send({
                message: PB.toJson(
                    PB.fromObject("ModifyNicknameRequest", message)
                ),
            })
            .end((err, res) => {
                expect(res.status).to.equal(200, res.text);
                done();
            });
    });

    it("[POST]logout", (done) => {
        var message = {
            account: "test",
        };
        request
            .post("/logout")
            .set("Cookie", Cookies)
            .set("Connection", "keep alive")
            .set("Content-Type", "application/json")
            .type("form")
            .send({
                message: PB.toJson(PB.fromObject("LogoutRequest", message)),
            })
            .end((err, res) => {
                expect(res.status).to.equal(200, res.text);
                done();
            });
    });

    /*it('[POST]deleteUser', ( done ) =>{
        request
        .post('/deleteUser')
        .set("Connection", "keep alive")
        .set("Content-Type", "application/json")
        .type("form")
        .send({"username": "test"})
        .end((err, res) => {
            expect(res.status).to.equal(200, res.text)
            done()
        })
    })*/
});
