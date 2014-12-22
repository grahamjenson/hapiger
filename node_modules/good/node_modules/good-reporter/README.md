# good-reporter

Basic interface for [good](https://github.com/hapijs/good) reporter plugins.

![Build Status](https://travis-ci.org/hapijs/good-reporter.svg?branch=master) ![Current Version](https://img.shields.io/npm/v/good-reporter.svg)

Lead Maintainer: [Adam Bretz](https://github.com/arb)

## Usage

This is an abstraction module for implementing reporters for the [good](https://github.com/hapijs/good) process monitor plugin. It is generally used as a base object and various methods are over written for different reporters.

## Good Reporter
### new GoodReporter (events, [options])

creates a new GoodReporter object with the following arguments
- `events` - an object of key value pairs.
	- `key` - one of the supported [good events](https://github.com/hapijs/good) indicating the hapi event to subscribe to
	- `value` - a single string or an array of strings to filter incoming events. "\*" indicates no filtering. `null` and `undefined` are assumed to be "\*"
- `[options]` - optional arguments object

### `GoodReporter` methods
- `start(eventemitter, callback)` - starts the reporter and registers for the correct events emitted by the supplied event emitter. Any "run once" logic should be in the start method. For example, creating a database connection. If you need to override this function, you will need to register for the "report" event yourself and `bind` to `_handleEvent`. See the example below.
- `stop()` - stops the reporter. Should be used for any tear down logic such as clearing time outs or disconnecting from a database.
- `_report(event, eventData)` - _private_ method that implementations of `GoodReporter` *must* implement. You should never call this method directly. It will be called when the proper event has been emitted from the supplied event emitter.
- `_filter(event, eventData)` - _private_ method for filtering incoming events. Looks into `options.events` for a match on `event` and then further filters by the tags compared to `eventData.tags`. Returns `true` if the `event` + `[eventData.tags]` should be reported. You should never need to call `_filter` directly unless you need to over write any of the methods that use it.
- `_handleEvent(event, eventData)` - _private_ method used to handle incoming "report" events from the event emitter. If `_filter` returns true, `_report` will be called.
- `_register` - _private_ method used to set up event handlers for events this reporter cares about.

## Examples

Every new reporter *must* implement a `report()` method. This is where the logic of exactly how this reporter moves data from the received events to the destination. Everything else can be optional depending on the specific transmission method of `report`.

### "One Off" object

Below is a simple "one off" good-reporter object.

```javascript
var GoodReporter = require('good-reporter');
var EventEmitter = require('events').EventEmitter;

var reporter = new GoodReporter({
    request: '*',
    ops: '*'
});
var ee = new EventEmitter();
reporter._report = function (event, eventData) {

    if (event === 'request') {
        console.info(eventData.method);
    } else if (event === 'ops') {
        console.info(JSON.parse(eventData));
    }
};
reporter.start(ee, function (err) {

    ee.emit('request', 'request', { method: 'post' } );
});
```

### Reusable Reporter

If you are looking to create a custom and reusable reporter for [good](https://github.com/hapijs/good), your new object needs to inherit from `good-reporter`. You will also need to implement `report(event, eventData)` as well.

```javascript
var GoodReporter = require('good-reporter');
var Util = require('util');

var internals = {};

module.exports = internals.GoodTwitter = function (events, options) {

	GoodReporter.call(this, events);

	this._hashTag = "#goodlogs";
	this._account = "hapijs";
};

Hoek.inherits(internals.GoodFile, GoodTwitter);

internals.GoodTwitter.prototype.start = function (emitter, callback) {

    // Register for the "report" event
    emitter.on('report', this._handleEvent.bind(this));
    // Open a socket to the Twitter API
    Tweet.open('https://twitter.com/hapijs', function (err, result) {

        this._connection = result;
        return callback(err);
    });
};

internals.GoodTwitter.prototype.stop = function () {

	// Send a final Tweet for the day, then close the open connection
	this._connection.send(this._hashTag + ' signing off for the day.', function (err) {

	    this._connection.close();
	});
};


internals.GoodTwitter.prototype._report = function (event, eventData) {

	this._connection.send(JSON.parse(eventData) + ' ' + this._hashTag);
};
```

In this example, you need to call the `GoodReporter` constructor to set up the internal state. Afterward you can write any custom logic that your specific broadcaster needs.
