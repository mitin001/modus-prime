'use strict';

const userAgentModule = require('ua-parser-js');
const eventParsers = {
  parseUserAgent: event => {
    if (event && event.requestContext && event.requestContext.identity) {
      return userAgentModule(event.requestContext.identity.userAgent);
    }
    return {};
  },
  isIncognito: event => {
    if (event && event.queryStringParameters && event.queryStringParameters.incognito) {
      return event.queryStringParameters.incognito == 1;
    }
    return false;
  }
};
module.exports = eventParsers;
