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
