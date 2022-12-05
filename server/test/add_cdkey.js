const supertest = require("supertest");
const chai = require("chai");
const app = require("../app");
const logger = require("../utils/log");
const Cdkey = require("../models/cdkey");

const expect = chai.expect;

let server = app.startup();

const request = supertest(server);
const PB = require("../utils/pb");

function makeid(length) {
    var result = "";
    var characters =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    var charactersLength = characters.length;
    for (var i = 0; i < length; i++) {
        result += characters.charAt(
            Math.floor(Math.random() * charactersLength)
        );
    }
    return result;
}

describe("add cdkey", () => {
    it("add cdkey", (done) => {
        let promises = [];

        for (let i = 0; i < 10; i++) {
            new_cdkey = new Cdkey({
                key: makeid(16),
            });

            promises.push( new_cdkey.save());
        }
        Promise.all(promises).then(()=>{done()});
    });
});
