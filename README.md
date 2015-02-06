<img src="./assets/hapiger300x200.png" align="right" alt="HapiGER logo" />

Providing good recommendations can create greater user engagement and directly provide value by recommending items the customer might additionally like. However, many applications don't provide recommendations to users because of the difficulty in implementing a custom engine or the pain of using an off-the-shelf engine.

**HapiGER** is a recommendations service that uses the Good Enough Recommendations (**GER**), a scalable simple recommendation engine, and the [Hapi.js](http://hapijs.org) framework. It has been developed to be easy to integrate, easy to use and scalable.

[Project Site](http://www.hapiger.com)

#Quick Start Guide

##Install HapiGER

```bash
npm install -g hapiger
```

## Start HapiGER

Start with Memory Event Store (events are not persisted)

```bash
hapiger
```

##Give an Action Weight

```bash
curl -X POST 'http://localhost:3456/default/actions' -d'{
    "name": "view", 
    "weight": 1
  }'
```

## Create some Events

`Alice` `view`s `Harry Potter` 

```bash
curl -X POST 'http://localhost:3456/default/events' -d '{
    "person":"Alice", 
    "action": "view", 
    "thing":"Harry Potter"
  }' 
```

Then, `Bob` also `views` `Harry Potter` (so `Bob` has similar viewing habits to `Alice`)

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

## Get Recommendations

What books should `Alice` `buy`?

```bash
curl -X GET 'http://localhost:3456/default/recommendations?person=Alice&action=buy'
```

```JSON
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

`Alice` should by `The Hobbit` with a weight of about `0.2`, it was recommended by `Bob`.

*The `confidence` of these recommendations is pretty low because there are not many events in the system*

# How HapiGER Works (The Quick Version)

The HapiGER API calculates recommendations for `Alice` to `buy` by:

1. Finding similar people to `Alice` by looking at her past events
2. Calculating the similarities from `Alice` to the list of people
3. Finding a list of the most recent `thing`s the similar people `buy`
4. Calculating the weights of `thing`s using the similarity of the people

*If you would like to read more about how HapiGER works, here is [the long version](http://www.maori.geek.nz/post/how_ger_generates_recommendations_the_anatomy_of_a_recommendations_engine).*

# Other Features

## Event Stores

The in memory event store is the default, though this is not recommended for production use. The **recommended** event store is PostgreSQL, which can be used with:

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

## Compacting the Event Store

The event store needs to be regularly maintained by removing old outdated or superfluous events, this is compacting. This can be done either synchronously or asynchronously:

```
curl -X POST 'http://localhost:3456/default/compact'
```


```
curl -X POST 'http://localhost:3456/default/compact_async'
```


## Namespaces

Namespaces are used to separate events for different applications or categories of things. The default namespace is `default`, you can create namespaces by:

```
curl -X POST 'http://localhost:3456/namespace' -d'{
    "namespace": "newnamespace"
  }'  
```

To delete a namespace:

```
curl -X DELETE 'http://localhost:3456/namespace/movies'
```

## Configuration of HapiGER

There are many available configuration variables for HapiGER, which can be viewed with `hapiger --help`. To understand the impact of these please read the [the long version](http://www.maori.geek.nz/post/how_ger_generates_recommendations_the_anatomy_of_a_recommendations_engine) of how HapiGER works.

# Clients

1. Node.js client [ger-client](https://www.npmjs.com/package/ger-client)

# Changelog

###TODO
