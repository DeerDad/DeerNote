const logger = require("../utils/log");
var events = require('events');
var eventEmitter = new events.EventEmitter();

const ErrorCodes = {
  DefaultError: 0,
  ParamError: 1,
  DBQueryError: 2,
  UserDoesnotExists: 3,
  WrongPassword: 4,
  UserAlreadyExists: 5,
  UserFoldersDoesnotExists: 6,
  NoteDoesnotExists: 7,
  UnAuth:8,
  UserDoesnotMatch:9,
  RegisterNeedKey:10,
};

const ErrorTips = {
  0: "internal error",
  1: "param error",
  2: "db query error",
  3: "user does not exist",
  4: "wrong password",
  5: "user already exists",
};

// middlewares/catcherror.js
class HttpException extends Error {
  constructor(errorCode = ErrorCodes.DefaultError) {
    super();
    this.errorCode = errorCode;
    this.msg = ErrorTips[errorCode] || `${errorCode} error no tips`;
  }
}

const catchError = async (ctx, next) => {
  try {
    await next();
  } catch (err) {
    if (err instanceof HttpException) {
      ctx.status = err.errorCode + 600;
      ctx.body = err.msg;
    } else {
      ctx.status = 500;
      ctx.body = err.message;
    }

    eventEmitter.emit('error', err); 
  }
};

eventEmitter.on('error', (err) => {
  if (err instanceof HttpException) {
    logger.warn(err.msg);
  } else {
    logger.error(err);
  }
});

module.exports = {
  catchError: catchError,
  HttpException: HttpException,
  ErrorCodes: ErrorCodes,
};
