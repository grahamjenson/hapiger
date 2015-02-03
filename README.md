<img src="./assets/hapiger300x200.png" align="right" alt="HapiGER logo" />

Providing good recommendations can create greater user engagement and directly provide value by recommending items the customer might additionally like. However, many applications don't provide recommendations to users because of the difficulty in implementing a custom engine or difficulty using an off-the-shelf engine.

Good Enough Recommendations (**GER**) is a scalable simple recommendation engine and **HapiGER** is an HTTP service wrapping GER using the [Hapi.js](http://hapijs.org) framework.

#Quick Start Guide

##Install HapiGER

```
npm install -g hapiger
```

## Start HapiGER

Start with Memory Event Store (events are not persisted)

```
hapiger --es memory
```

Start with PostgreSQL Event Store (options are passed to [knex](http://knexjs.org/))

```
hapiger --es pg --esoptions '{
    "connection":"postgres://localhost/hapiger"
  }'  
```

Start with RethinkDB Event Store (options passed to [rethinkdbdash](https://github.com/neumino/rethinkdbdash))

```
hapiger --es rethinkdb --esoptions '{
    "host":"127.0.0.1",
    "port": 28015,
    "db":"hapiger"
  }'
```


## Create an Event

```
curl -X POST 'http://localhost:3456/default/events' -d '{
    "person":"p1", 
    "action": "view", 
    "thing":"t1"
  }'  
```

##Create an Action

```
curl -X POST 'http://localhost:3456/default/actions' -d'{
    "name": "view", 
    "weight": 1
  }'
```

## Get Recommendations

```
curl -X GET 'http://localhost:3456/default/recommendations?person=p1&action=view'
```

## Compact the Event Store

```
curl -X POST 'http://localhost:3456/default/compact'
```

# Namespaces

Namespaces are used to separate events.

## Create a Namespace

```
curl -X POST 'http://localhost:3456/namespace' -d'{
    "namespace": "newnamespace"
  }'  
```

## Delete Namespace (and all events in it!)

```
curl -X DELETE 'http://localhost:3456/namespace/movies'
```

#Documentation

###TODO

# Posts
1. Overall description and motivation of GER: [Good Enough Recommendations with GER](http://maori.geek.nz/post/good_enough_recomendations_with_ger)
2. How GER works [GER's Anatomy: How to Generate Good Enough Recommendations](http://www.maori.geek.nz/post/how_ger_generates_recommendations_the_anatomy_of_a_recommendations_engine)

# Changelog

###TODO
