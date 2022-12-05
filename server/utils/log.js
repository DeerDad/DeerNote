var log4js = require("log4js");
var config = require("config")

log4js.configure({
    appenders: {
        console: {
             type: "console" 
        },
        app: { 
            type: "file", filename: "server.log"
        }, 
    },
    categories: { default: { appenders: ["console", "app"], level: config.get("log_config.log_level") } },
  });

const logger = log4js.getLogger()

logger.dumpStack = function() {
    var stack = new Error().stack
    this.trace(stack);
}

module.exports = logger