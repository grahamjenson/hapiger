# HapiGER

<img src="./assets/hapiger300x200.png" align="right" alt="HapiGER logo" />

Providing good recommendations can create greater user engagement and directly provide value by recommending items the customer might additionally like. However, many applications don't provide recommendations to users because of the difficulty in implementing a custom engine or the pain of using an off-the-shelf engine.

**HapiGER** is a recommendations service that uses the [Good Enough Recommendations (**GER**)](https://www.npmjs.com/package/ger), a scalable, simple recommendations engine, and the [Hapi.js](http://hapijs.org) framework. It has been developed to be easy to integrate, easy to use and very scalable.

[Project Site](http://www.hapiger.com)

## Quick Start Guide

<br/>
***
#### Install HapiGER

Install with `npm`

```bash
npm install -g hapiger
```

<br/>
***

#### Start HapiGER

By default it will start with an in-memory event store (events are not persisted)

```bash
hapiger
```

*There are also PostgreSQL and RethinkDB event stores for persistence and scaling*

<br/>
***

#### Give an Action Weight

Set the `view` action to have weight `1`:

```bash
curl -X POST 'http://localhost:3456/default/actions' -d'{
    "name": "view", 
    "weight": 1
  }'
```

<br/>
***

#### Create some Events

`Alice` `view`s `Harry Potter` 

```bash
curl -X POST 'http://localhost:3456/default/events' -d '{
    "person":"Alice", 
    "action": "view", 
    "thing":"Harry Potter"
  }' 
```

Then, `Bob` also `view`s `Harry Potter` (now `Bob` has similar viewing habits to `Alice`)

```bash
curl -X POST 'http://localhost:3456/default/events' -d '{
    "person":"Bob", 
    "action": "view", 
    "thing":"Harry Potter"
  }'
```

`Bob` then `buy`s `The Hobbit`

```bash
curl -X POST 'http://localhost:3456/default/events' -d '{
    "person":"Bob", 
    "action": "buy", 
    "thing":"The Hobbit"
  }'
```

<br/>
***

#### Get Recommendations

What books should `Alice` `buy`?

```bash
curl -X GET 'http://localhost:3456/default/recommendations?person=Alice&action=buy'
```

```
{
  "recommendations":[
    {
      "thing":"The Hobbit",
      "weight":0.22119921692859512,
      "people":[
        "Bob"
      ],
      "last_actioned_at":"2015-02-05T05:56:42.862Z"
    }
  ],
  "confidence":0.00019020140391302825,
  "similar_people":{
    "Bob":1
  }
}
```

`Alice` should buy `The Hobbit` as it was recommended by `Bob` with a weight of about `0.2`.

*The `confidence` of these recommendations is pretty low because there are not many events in the system*

<br/>
*** 

#### How HapiGER Works (the Quick Version)

The HapiGER API calculates recommendations for `Alice` to `buy` by:

1. Finding people that are like `Alice` by looking at her past events
2. Calculating the similarities between `Alice` and those people
3. Look at the recent `things` that those similar people `buy`
4. Weight those `thing`s using the similarity of the people

*If you would like to read more about how HapiGER works, here is [the long version](http://www.maori.geek.nz/post/how_ger_generates_recommendations_the_anatomy_of_a_recommendations_engine).*

<br/>
***

#### Event Stores

The "in-memory" memory event store is the default, this will not scale well or persist event so is not recommended for production. 

The **recommended** event store is **PostgreSQL**, which can be used with:

```
hapiger --es pg --esoptions '{
    "connection":"postgres://localhost/hapiger"
  }'  
```

*Options are passed to [knex](http://knexjs.org/).*

HapiGER also supports a [RethinkDB](http://rethinkdb.com/) event store:

```
hapiger --es rethinkdb --esoptions '{
    "host":"127.0.0.1",
    "port": 28015,
    "db":"hapiger"
  }'
```

*Options passed to [rethinkdbdash](https://github.com/neumino/rethinkdbdash).*

<br/>
***

#### Compacting the Event Store

The event store needs to be regularly maintained by removing old, outdated, or superfluous events; this is called **compacting**. This can be done either synchronously or asynchronously (it can take a while):

```
curl -X POST 'http://localhost:3456/default/compact'
```

```
curl -X POST 'http://localhost:3456/default/compact_async'
```

<br/>
***

#### Namespaces

Namespaces are used to separate events for different applications or categories of things. The default namespace is `default`, but you can create namespaces by:

```
curl -X POST 'http://localhost:3456/namespace' -d'{
    "namespace": "newnamespace"
  }'  
```

To delete a namespace (**and all its events!**):

```
curl -X DELETE 'http://localhost:3456/namespace/movies'
```

<br/>
***

#### Configuration of HapiGER

There are many configuration variables for HapiGER to tune the generated recommendations, these can be viewed with `hapiger --help`. The impact of each of these options are described in [the long version](http://www.maori.geek.nz/post/how_ger_generates_recommendations_the_anatomy_of_a_recommendations_engine) of how HapiGER works.

<br/>
***

#### Clients

1. Node.js client [ger-client](https://www.npmjs.com/package/ger-client)

## Changelog

8/02/15 -- Updated readme and bumped version
