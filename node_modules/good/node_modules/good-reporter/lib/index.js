// Load modules

var Hoek = require('hoek');

// Declare internals

var internals = {};

internals.buildFilter = function (events) {

    var result = {};
    var subs = Object.keys(events);
    for (var i = 0, il = subs.length; i < il; ++i) {
        var key = subs[i];
        var filter = events[key];
        var tags = Array.isArray(filter) ? filter : [];

        if (filter && filter !== '*') {
            tags = tags.concat(filter);
        }

        // Force everything to be a string
        for (var j = 0, jl = tags.length; j < jl; ++j) {
            tags[j] = '' + tags[j];
        }

        result[key] = tags;
    }
    return result;
};


module.exports = internals.GoodReporter = function (events, options) {

    Hoek.assert(this.constructor === internals.GoodReporter
        || this.constructor.super_ === internals.GoodReporter, 'GoodReporter must be created with new');

    options = options || {};
    events = events || {};

    this._events = internals.buildFilter(events);
    this._settings = options;
};


internals.GoodReporter.prototype.start = function (emitter, callback) {

    emitter.on('report', this._handleEvent.bind(this));
    return callback(null);
};


internals.GoodReporter.prototype.stop = function () {};


internals.GoodReporter.prototype._report = function (event, eventData) {

    throw new Error('Instance of GoodReporter must implement their own "_report" function.');
};


internals.GoodReporter.prototype._filter = function (event, eventData) {

    var subEventTags = this._events[event];

    // If we aren't interested in this event, break
    if (!subEventTags) {
        return false;
    }

    // If it's an empty array, we do not want to do any filtering
    if (subEventTags.length === 0) {
        return true;
    }

    // Check event tags to see if one of them is in this reports list
    if (Array.isArray(eventData.tags)) {
        var result = false;
        for (var i = 0, il = eventData.tags.length; i < il; ++i) {
            var eventTag = eventData.tags[i];
            result = result || subEventTags.indexOf(eventTag) > -1;
        }

        return result;
    }

    return false;
};


internals.GoodReporter.prototype._handleEvent = function (event, eventData) {

    if (this._filter(event, eventData)) {
        this._report(event, eventData);
    }
};