// Load modules

var Util = require('util');
var GoodReporter = require('good-reporter');
var Hoek = require('hoek');
var Moment = require('moment');
var SafeStringify = require('json-stringify-safe');

// Declare internals

var internals = {
    defaults: {
        format: 'YYMMDD/HHmmss.SSS',
        utc: true
    }
};

module.exports = internals.GoodConsole = function (events, options) {

    Hoek.assert(this.constructor === internals.GoodConsole, 'GoodConsole must be created with new');
    options = options || {};
    var settings = Hoek.applyToDefaults(internals.defaults, options);

    GoodReporter.call(this, events, settings);
};

Hoek.inherits(internals.GoodConsole, GoodReporter);


internals.GoodConsole.prototype._report = function (event, eventData) {

    var tags = (eventData.tags || []).concat([]);
    tags.unshift(event);

    if (event === 'response') {
        return this._formatResponse(eventData, tags);
    }

    var eventPrintData = {
        timestamp: eventData.timestamp,
        tags: tags,
        data: undefined
    };

    if (event === 'ops') {
        eventPrintData.data = 'memory: ' + Math.round(eventData.proc.mem.rss / (1024 * 1024)) +
        'Mb, uptime (seconds): ' + eventData.proc.uptime +
        ', load: ' + eventData.os.load;
        return this._printEvent(eventPrintData);
    }

    if (event === 'error') {
        eventPrintData.data = 'message: ' + eventData.error.message + ' stack: ' + eventData.error.stack;
        return this._printEvent(eventPrintData);
    }

    if (event === 'request' || event === 'log') {
        eventPrintData.data = 'data: ' + (typeof eventData.data === 'object' ? SafeStringify(eventData.data) : eventData.data);
        return this._printEvent(eventPrintData, this._settings.format);
    }

    var m = Moment.utc(eventData.timestamp || Date.now());
    if (!this._settings.utc) { m.local(); }
    var timestring = m.format(this._settings.format);

    console.log('Unknown event "%s" occurred with timestamp %s.', event, timestring);
};


internals.GoodConsole.prototype._printEvent = function (event) {

    var m = Moment.utc(event.timestamp);

    if (!this._settings.utc) { m.local(); }

    var timestring = m.format(this._settings.format);
    var data = event.data;
    var output = timestring + ', [' + event.tags.toString() + '], ' + data;

    console.log(output);
};


internals.GoodConsole.prototype._formatResponse = function (event, tags) {

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

    this._printEvent({
        timestamp: event.timestamp,
        tags: tags,
        //instance, method, path, query, statusCode, responseTime, responsePayload
        data: Util.format('%s: %s %s %s %s (%sms) %s', event.instance, method, event.path, query, statusCode, event.responseTime, responsePayload)
    });
};
