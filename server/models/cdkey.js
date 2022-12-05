let mongoose = require("mongoose");

const cdkey_schema = new mongoose.Schema({
  key: { type: String, unique: true },
});
const cdkey_model = mongoose.model("cdkeys", cdkey_schema);
module.exports = cdkey_model;
