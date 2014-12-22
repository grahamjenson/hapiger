// Load modules

var Util = require('util');
var GoodReporter = require('good-reporter');
var Hoek = require('hoek');
var Moment = require('moment');
var SafeStringify = require('json-stringify-safe');

// Declare internals

var internals = {
    defaults: {
        format: 'YYMMDD/HHmmss.SSS'
    }
};

module.exports = internals.GoodConsole = function (events, options) {

    Hoek.assert(this.constructor === internals.GoodConsole, 'GoodConsole must be created with new');
    options = options || {};
    var settings = Hoek.applyToDefaults(internals.defaults, options);

    GoodReporter.call(this, events, settings);
};

Hoek.inherits(internals.GoodConsole, GoodReporter);

internals.printEvent = function (event, format) {

    var m = Moment.utc(event.timestamp);
    var timestring = m.format(format);
    var data = event.data;
    var output = timestring + ', ' + event.tags.toString() + ', ' + data;

    console.log(output);
};

internals.printResponse = function (event, format) {

    var query = event.query ? JSON.stringify(event.query) : '';
    var responsePayload = '';
    var statusCode = '';

    if (typeof event.responsePayload === 'object' && event.responsePayload) {
        responsePayload = 'response payload: ' + SafeStringify(event.responsePayload);
    }

    var methodColors = {
        get: 32,
        delete: 31,
        put: 36,
        post: 33
    };
    var color = methodColors[event.method] || 34;
    var method = '\x1b[1;' + color + 'm' + event.method + '\x1b[0m';

    if (event.statusCode) {
        color = 32;
        if (event.statusCode >= 500) {
            color = 31;
        } else if (event.statusCode >= 400) {
            color = 33;
        } else if (event.statusCode >= 300) {
            color = 36;
        }
        statusCode = '\x1b[' + color + 'm' + event.statusCode + '\x1b[0m';
    }

    internals.printEvent({
        timestamp: event.timestamp,
        tags: ['response'],
        //instance, method, path, query, statusCode, responseTime, responsePayload
        data: Util.format('%s: %s %s %s %s (%sms) %s', event.instance, method, event.path, query, statusCode, event.responseTime, responsePayload)
    }, format);

};

internals.GoodConsole.prototype._report = function (event, eventData) {

    if (event === 'ops') {
        internals.printEvent({
            timestamp: eventData.timestamp,
            tags: ['ops'],
            data: 'memory: ' + Math.round(eventData.proc.mem.rss / (1024 * 1024)) +
            'Mb, uptime (seconds): ' + eventData.proc.uptime +
            ', load: ' + eventData.os.load
        }, this._settings.format);
    }
    else if (event === 'response') {
        internals.printResponse(eventData, this._settings.format);
    }
    else if (event === 'error') {
        internals.printEvent({
            timestamp: eventData.timestamp,
            tags: ['internalError'],
            data: 'message: ' + eventData.error.message + ' stack: ' + eventData.error.stack
        }, this._settings.format);
    }
    else if (event === 'request') {
        var tags = eventData.tags.concat([]);
        tags.unshift(event);
        internals.printEvent({
            timestamp: eventData.timestamp,
            tags: tags,
            data: 'data: ' + (typeof eventData.data === 'object' ? SafeStringify(eventData.data) : eventData.data)
        }, this._settings.format);
    }
    else if (event === 'log') {
        internals.printEvent({
            timestamp: eventData.timestamp,
            tags: eventData.tags,
            data: typeof eventData.data === 'object' ? SafeStringify(eventData.data) : eventData.data
        }, this._settings.format);
    }
    else {
        var m = Moment.utc(eventData.timestamp || Date.now());
        var timestring = m.format(this._settings.format);

        console.log('Unknown event "%s" occurred with timestamp %s.', event, timestring);
    }
};
