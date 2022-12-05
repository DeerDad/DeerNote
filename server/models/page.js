let mongoose = require("mongoose");

const page_schema = new mongoose.Schema({
  uuid: { type: String, unique: true },
  message: String,
});

const page_model = mongoose.model("pages", page_schema);
module.exports = page_model;
