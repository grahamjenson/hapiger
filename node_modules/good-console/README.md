# good-console

Console broadcasting for Good process monitor

[![Build Status](https://travis-ci.org/hapijs/good-console.svg?branch=master)](http://travis-ci.org/hapijs/good-console)![Current Version](https://img.shields.io/npm/v/good-console.svg)

Lead Maintainer: [Adam Bretz](https://github.com/arb)

## Usage

`good-console` is a [good-reporter](https://github.com/hapijs/good-reporter) implementation to write [hapi](http://hapijs.com/) server events to the console.

## Good Console
### new GoodConsole(events, [options])
creates a new GoodFile object with the following arguments

- `events` - an object of key value pairs.
	- `key` - one of the supported [good events](https://github.com/hapijs/good) indicating the hapi event to subscribe to
	- `value` - a single string or an array of strings to filter incoming events. "\*" indicates no filtering. `null` and `undefined` are assumed to be "\*"
- `[options]` -
	- `format` - [MomentJS](http://momentjs.com/docs/#/displaying/format/) format string. Defaults to 'YYMMDD/HHmmss.SSS'.
	- `utc` - boolean controlling Moment using [utc mode](http://momentjs.com/docs/#/parsing/utc/) or not. Defaults to `true`.

### Output Formats

Below are example outputs for the designated event type:

- "ops" - 141225/093015.900, [ops, `event.tags`], memory: 10Mb, uptime (seconds): 1000, load: [ 1.650390625, 1.6162109375, 1.65234375 ]
- "error" - 141225/093015.900, [error, `event.tags`], message: there was an error, stack: `eventData.stack`
- "request" - 141225/093015.900, [request, `event.tags`], data: {"message":"you made a request to a resource"}
- "log" - 141225/093015.900, [log, `event.tags`], data: you logged a message
- "response" - 141223/164207.694, [response], localhost: post /data {"name":"adam"} 200 (150ms) response payload: {"foo":"bar","value":1}