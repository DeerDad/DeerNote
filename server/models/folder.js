let mongoose = require("mongoose");

const folder_schema = new mongoose.Schema({
  account: { type: String, unique: true },
  message: String,
});

const folder_model = mongoose.model("folders", folder_schema);
module.exports = folder_model;
