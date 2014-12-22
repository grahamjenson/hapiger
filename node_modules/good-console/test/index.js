// Load modules
var EventEmitter = require('events').EventEmitter;
var Util = require('util');
var Code = require('code');
var Hoek = require('hoek');
var Lab = require('lab');
var Moment = require('moment');
var GoodConsole = require('..');


// Declare internals

var internals = {
    defaults: {
        format: 'YYMMDD/HHmmss.SSS'
    }
};
internals.ops = {
    event: 'ops',
    timestamp: 1411583264547,
    os: {
        load: [ 1.650390625, 1.6162109375, 1.65234375 ],
        mem: { total: 17179869184, free: 8190681088 },
        uptime: 704891
    },
    proc: {
        uptime: 6,
        mem: {
            rss: 30019584,
            heapTotal: 18635008,
            heapUsed: 9989304
        },
        delay: 0.03084501624107361
    },
    load: { requests: {}, concurrents: {}, responseTimes: {} },
    pid: 64291
};
internals.response = {
    event: 'response',
    method: 'post',
    statusCode: 200,
    timestamp: Date.now(),
    instance: 'localhost',
    path: '/data',
    responseTime: 150,
    query: {
        name: 'adam'
    },
    responsePayload: {
        foo:'bar',
        value: 1
    }
};
internals.request = {
    event: 'request',
    timestamp: 1411583264547,
    tags: ['user', 'info'],
    data: 'you made a request',
    pid: 64291,
    id: '1419005623332:new-host.local:48767:i3vrb3z7:10000',
    method: 'get',
    path: '/'
};

// Test shortcuts

var lab = exports.lab = Lab.script();
var expect = Code.expect;
var before = lab.before;
var after = lab.after;
var describe = lab.describe;
var it = lab.it;

describe('GoodConsole', function () {

    var log;

    before(function (done) {

        log = console.log;
        done();
    });

    after(function (done) {

        console.log = log;
        done();
    });

    it('throw an error is not constructed with new', function (done) {

        expect(function () {

            var reporter = GoodConsole();
        }).to.throw('GoodConsole must be created with new');
        done();
    });

    describe('_report()', function () {

        describe('printResponse()', function () {

            it('logs to the console for "response" events', function (done) {

                var reporter = new GoodConsole({ response: '*' });
                var now = Date.now();
                var timeString = Moment.utc(now).format(internals.defaults.format);
                var ee = new EventEmitter();

                console.log = function (value) {

                    expect(value).to.equal(timeString + ', response, localhost: [1;33mpost[0m /data {"name":"adam"} [32m200[0m (150ms) response payload: {"foo":"bar","value":1}');
                    done();
                };

                internals.response.timestamp = now;

                reporter.start(ee, function (err) {

                    expect(err).to.not.exist();

                    ee.emit('report', 'response', internals.response);
                });
            });

            it('logs to the console for "response" events without a query', function (done) {

                var reporter = new GoodConsole({ response: '*' });
                var now = Date.now();
                var timeString = Moment.utc(now).format(internals.defaults.format);
                var event = Hoek.clone(internals.response);
                var ee = new EventEmitter();

                delete event.query;

                console.log = function (value) {

                    expect(value).to.equal(timeString + ', response, localhost: [1;33mpost[0m /data  [32m200[0m (150ms) response payload: {"foo":"bar","value":1}');
                    done();
                };

                event.timestamp = now;

                reporter.start(ee, function (err) {

                    expect(err).to.not.exist();
                    ee.emit('report', 'response', event);
                });
            });

            it('logs to the console for "response" events without a responsePayload', function (done) {

                var reporter = new GoodConsole({ response: '*' });
                var now = Date.now();
                var timeString = Moment.utc(now).format(internals.defaults.format);
                var event = Hoek.clone(internals.response);
                var ee = new EventEmitter();

                delete event.responsePayload;

                console.log = function (value) {

                    expect(value).to.equal(timeString + ', response, localhost: [1;33mpost[0m /data {"name":"adam"} [32m200[0m (150ms) ');
                    done();
                };

                event.timestamp = now;

                reporter.start(ee, function (err) {

                    expect(err).to.not.exist();
                    ee.emit('report', 'response', event);
                });
            });

            it('provides a default color for response methods', function (done) {

                var reporter = new GoodConsole({ response: '*' });
                var now = Date.now();
                var timeString = Moment.utc(now).format(internals.defaults.format);
                var event = Hoek.clone(internals.response);
                var ee = new EventEmitter();

                console.log = function (value) {

                    expect(value).to.equal(timeString + ', response, localhost: [1;34mhead[0m /data {"name":"adam"} [32m200[0m (150ms) response payload: {"foo":"bar","value":1}');
                    done();
                };

                event.timestamp = now;
                event.method = 'head';

                reporter.start(ee, function (err) {

                    expect(err).to.not.exist();
                    ee.emit('report', 'response', event);
                });
            });

            it('does not log a status code if there is not one attached', function (done) {

                var reporter = new GoodConsole({ response: '*' });
                var now = Date.now();
                var timeString = Moment.utc(now).format(internals.defaults.format);
                var event = Hoek.clone(internals.response);
                var ee = new EventEmitter();

                console.log = function (value) {

                    expect(value).to.equal(timeString + ', response, localhost: [1;33mpost[0m /data {"name":"adam"}  (150ms) response payload: {"foo":"bar","value":1}');
                    done();
                };

                event.timestamp = now;
                delete event.statusCode;

                reporter.start(ee, function (err) {

                    expect(err).to.not.exist();
                    ee.emit('report', 'response', event);
                });

            });

            it('uses different colors for different status codes', function (done) {

                var counter = 1;
                var reporter = new GoodConsole({ response: '*' });
                var now = Date.now();
                var timeString = Moment.utc(now).format(internals.defaults.format);
                var colors = {
                    1: 32,
                    2: 32,
                    3: 36,
                    4: 33,
                    5: 31
                };
                var ee = new EventEmitter();

                console.log = function (value) {

                    var expected = Util.format('%s, response, localhost: [1;33mpost[0m /data  [%sm%s[0m (150ms) ', timeString, colors[counter], counter * 100);
                    expect(value).to.equal(expected);
                    counter++;

                    if (counter === 5) { done(); }
                };


                reporter.start(ee, function (err) {

                    expect(err).to.not.exist();

                    for (var i = 1; i < 6; ++i) {
                        var event = Hoek.clone(internals.response);
                        event.statusCode = i * 100;
                        event.timestamp = now;

                        delete event.query;
                        delete event.responsePayload;

                        ee.emit('report', 'response', event);
                    }
                });
            });
        });

        it('prints ops events', function (done) {

            var reporter = new GoodConsole({ ops: '*' });
            var now = Date.now();
            var timeString = Moment.utc(now).format(internals.defaults.format);
            var event = Hoek.clone(internals.ops);
            var ee = new EventEmitter();

            console.log = function (value) {

                expect(value).to.equal(timeString + ', ops, memory: 29Mb, uptime (seconds): 6, load: 1.650390625,1.6162109375,1.65234375');
                done();
            };

            event.timestamp = now;

            reporter.start(ee, function (err) {

                expect(err).to.not.exist();
                ee.emit('report', 'ops', event);
            });
        });

        it('prints error events', function (done) {

            var reporter = new GoodConsole({ error: '*' });
            var now = Date.now();
            var timeString = Moment.utc(now).format(internals.defaults.format);
            var event = {
                event: 'error',
                error: {
                    message: 'test message',
                    stack: 'fake stack for testing'
                }
            };
            var ee = new EventEmitter();

            console.log = function (value) {

                expect(value).to.equal(timeString + ', internalError, message: test message stack: fake stack for testing');
                done();
            };

            event.timestamp = now;

            reporter.start(ee, function (err) {

                expect(err).to.not.exist();
                ee.emit('report', 'error', event);
            });
        });

        it('prints request events with string data', function (done) {

            var reporter = new GoodConsole({ request: '*' });
            var now = Date.now();
            var timeString = Moment.utc(now).format(internals.defaults.format);
            var ee = new EventEmitter();

            console.log = function (value) {

                expect(value).to.equal(timeString + ', request,user,info, data: you made a request');
                done();
            };

            internals.request.timestamp = now;

            reporter.start(ee, function (err) {

                expect(err).to.not.exist();
                ee.emit('report', 'request', internals.request);
            });
        });

        it('prints request events with object data', function (done) {

            var reporter = new GoodConsole({ request: '*' });
            var now = Date.now();
            var timeString = Moment.utc(now).format(internals.defaults.format);
            var ee = new EventEmitter();

            console.log = function (value) {

                expect(value).to.equal(timeString + ', request,user,info, data: {"message":"you made a request to a resource"}');
                done();
            };

            internals.request.timestamp = now;
            internals.request.data = { message: 'you made a request to a resource' };

            reporter.start(ee, function (err) {

                expect(err).to.not.exist();
                ee.emit('report', 'request', internals.request);
            });
        });

        it('prints a warning message for unknown event types', function (done) {

            var reporter = new GoodConsole({ test: '*' });
            var event = {
                event: 'test',
                data: {
                    reason: 'for testing'
                },
                tags: ['user']
            };
            var ee = new EventEmitter();

            console.log = function (value) {

                expect(value).to.equal('Unknown event "%s" occurred with timestamp %s.');
                done();
            };

            reporter.start(ee, function (err) {

                expect(err).to.not.exist();
                ee.emit('report', 'test', event);
            });
        });

        it('prints log events with string data', function (done) {

            var reporter = new GoodConsole({ log: '*' });
            var now = Date.now();
            var timeString = Moment.utc(now).format(internals.defaults.format);
            var ee = new EventEmitter();

            console.log = function (value) {

                expect(value).to.equal(timeString + ', info, this is a log');
                done();
            };

            internals.request.timestamp = now;

            reporter.start(ee, function (err) {

                expect(err).to.not.exist();
                ee.emit('report', 'log', {
                    timestamp: now,
                    tags: ['info'],
                    data: 'this is a log'
                });
            });
        });

        it('prints log events with object data', function (done) {

            var reporter = new GoodConsole({ log: '*' });
            var now = Date.now();
            var timeString = Moment.utc(now).format(internals.defaults.format);
            var ee = new EventEmitter();

            console.log = function (value) {

                console.info(value);

                expect(value).to.equal(timeString + ', info,high, {"message":"this is a log"}');
                done();
            };

            internals.request.timestamp = now;

            reporter.start(ee, function (err) {

                expect(err).to.not.exist();
                ee.emit('report', 'log', {
                    timestamp: now,
                    tags: ['info', 'high'],
                    data: {
                        message: 'this is a log'
                    }
                });
            });
        });

        it('formats the timestamp based on the supplied option', function (done) {

            var reporter = new GoodConsole({ test: '*' }, { format: 'YYYY'});
            var now = Date.now();
            var timeString = Moment.utc(now).format('YYYY');
            var event = {
                event: 'test',
                data: {
                    reason: 'for testing'
                },
                tags: ['user']
            };
            var ee = new EventEmitter();

            console.log = function (value, event, time) {

                var result = Util.format(value, event, time);

                expect(result).to.equal('Unknown event "test" occurred with timestamp ' + timeString + '.');
                done();
            };
            event.timestamp = now;

            reporter.start(ee, function (err) {

                expect(err).to.not.exist();
                ee.emit('report', 'test', event);
            });
        });
    });
});
