let mongoose = require("mongoose");

const user_schema = new mongoose.Schema({
  account: { type: String, unique: true },
  message: String,
});
const user_model = mongoose.model("users", user_schema);
module.exports = user_model;
