var Code = require('code');
var EventEmitter = require('events').EventEmitter;
var Lab = require('lab');
var lab = exports.lab = Lab.script();
var GoodReporter = require('..');

var describe = lab.describe;
var it = lab.it;
var expect = Code.expect;

describe('GoodReporter', function() {

    it('throws an error without using new', function(done) {

        expect(function() {

            var reporter = GoodReporter();
        }).to.throw('GoodReporter must be created with new');

        done();
    });

    it('provides a start function', function (done) {

        var reporter = new GoodReporter();
        var ee = new EventEmitter();

        expect(reporter.start).to.exist();

        reporter.start(ee, function (error) {

            expect(error).to.not.exist();
            done();
        });
    });

    it('provides a stop function', function (done) {

        var reporter = new GoodReporter();
        expect(reporter.stop).to.exist();
        expect(reporter.stop()).to.equal(undefined);
        done();
    });

    it('converts *, null, undefined, 0, and false to an empty array, indicating all tags are acceptable', function (done) {

        var tags = ['*', null, undefined, false, 0];
        for (var i = 0, il = tags.length; i < il; ++i) {

            var reporter = new GoodReporter({
                error: tags[i]
            });

            expect(reporter._events.error).to.deep.equal([]);
        }

        done();
    });

    it('converts a single tag to an array', function (done) {

        var reporter = new GoodReporter({
            error: 'hapi'
        });

        expect(reporter._events.error).to.deep.equal(['hapi']);
        done();
    });

    describe('_filter()', function () {

        it('returns true if this reporter should report this event type', function (done) {

            var reporter = new GoodReporter({
                log: '*'
            });

            expect(reporter._filter('log', {
                tags: ['request', 'server', 'error', 'hapi']
            })).to.equal(true);

            done();
        });

        it('returns false if this report should not report this event type', function (done) {

            var reporter = new GoodReporter();

            expect(reporter._filter('ops', {
                tags: '*'
            })).to.equal(false);

            done();
        });

        it('returns true if the event is matched, but there are not any tags with the data', function (done) {

            var reporter = new GoodReporter({
                log: '*'
            });
            expect(reporter._filter('log', {
                tags: []
            })).to.equal(true);

            done();
        });

        it('returns false if the event is not matched', function (done) {

            var reporter = new GoodReporter();
            expect(reporter._filter('ops', {
                tags:[]
            })).to.equal(false);

            done();
        });

        it('returns false if the subscriber has tags, but the matched event does not have any', function (done) {

            var reporter = new GoodReporter({
                error: 'db'
            });

            expect(reporter._filter('error', {
                tags:[]
            })).to.equal(false);

            done();
        });

        it('returns true if the event and tag match', function (done) {

            var reporter = new GoodReporter({
                error: ['high', 'medium', 'log']
            });

            expect(reporter._filter('error', {
                tags: ['hapi', 'high', 'db', 'severe']
            })).to.equal(true);
            done();
        });

        it('returns false by default', function (done) {

           var reporter = new GoodReporter({
               events: {
                   request: 'hapi'
               }
           });

            expect(reporter._filter('request', {})).to.equal(false);
            done();
        });
    });

    describe('_report()', function () {

        it('throws an error if when called directly', function (done) {

            var reporter = new GoodReporter({
                request: '*'
            }, {
                key: 'value'
            });

            expect(function () {

                reporter._report();
            }).to.throw('Instance of GoodReporter must implement their own "_report" function.');
            done();
        });

    });

    describe('_handleEvent()', function() {

        it('runs when a matching event is emitted', function (done) {

            var ee = new EventEmitter();
            var reporter = new GoodReporter({
                request: '*',
                ops: '*',
                log: '*',
                error: '*'
            });
            var i = 1;
            var hash = {
                1:{
                    name: 'request',
                    value: { data:'request data' }
                },
                2: {
                    name: 'ops',
                    value: { data:'ops data' }
                },
                3: {
                    name: 'log',
                    value: { data:'log data' }
                },
                4: {
                    name: 'error',
                    value: { data:'error data' }
                }
            };

            reporter._report = function (event, eventData) {

                expect(hash[i].name).to.equal(event);
                expect(hash[i].value).to.deep.equal(eventData);
                i++;

                if (i > 4) {
                    ee.removeAllListeners();
                    return done();
                }
            };

            reporter.start(ee, function (err) {

                expect(err).to.not.exist();

                ee.emit('report', 'request', { data: 'request data' });
                ee.emit('report', 'ops', { data: 'ops data' });
                ee.emit('report', 'log', { data: 'log data' });
                ee.emit('report', 'error', { data: 'error data' });
            });

        });

        it('does not call report if the event is not matched', function (done) {


            var reporter = new GoodReporter({
                request: 'user'
            });
            var ee = new EventEmitter();

            reporter._report = function (event, eventData) {

                throw new Error('report called.');
            };

            reporter.start(ee, function (err) {
                expect(err).to.not.exist();

                expect(function() {
                    ee.emit('report', 'request', { data:'request data' });
                }).to.not.throw();
                done();
            });
        });
    });
});

