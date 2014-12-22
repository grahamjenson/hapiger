<img src="./assets/hapiger300x200.png" align="right" alt="HapiGER logo" />

Providing good recommendations can get greater user engagement and provide an opportunity to add value that would otherwise not exist. The main reason why many applications don't provide recommendations is the perceived difficulty in either implementing a custom engine or using an off-the-shelf engine.

Good Enough Recommendations (**GER**) is an attempt to reduce this difficulty by providing a recommendation engine that is scalable, easily usable and easy to integrate. HapiGER is an HTTP wrapper around GER implemented using the Hapi.js framework.

Posts about (or related to) GER:

1. Demo Movie Recommendations Site: [Yeah, Nah](http://yeahnah.maori.geek.nz/)
1. Overall description and motivation of GER: [Good Enough Recommendations with GER](http://maori.geek.nz/post/good_enough_recomendations_with_ger)
2. How GER works [GER's Anatomy: How to Generate Good Enough Recommendations](http://www.maori.geek.nz/post/how_ger_generates_recommendations_the_anatomy_of_a_recommendations_engine)
2. Testing frameworks being used to test GER: [Testing Javascript with Mocha, Chai, and Sinon](http://www.maori.geek.nz/post/introduction_to_testing_node_js_with_mocha_chai_and_sinon)
3. Bootstrap function for dumping data into GER: [Streaming directly into Postgres with Hapi.js and pg-copy-stream](http://www.maori.geek.nz/post/streaming_directly_into_postgres_with_hapi_js_and_pg_copy_stream)
4. [Postgres Upsert (Update or Insert) in GER using Knex.js](http://www.maori.geek.nz/post/postgres_upsert_update_or_insert_in_ger_using_knex_js)

#Quick Start Guide

To install hapiger

```
npm install -g hapiger
```

To start hapiger

```
hapiger
```

To create an event:

```
curl -X POST 'http://localhost:7890/default/event' -d '{person: "p1", action: "likes", thing: "x-men"}'
```

The `default` namespace is initialized on startup

To get recommendations for a user

```
curl -X GET 'http://localhost:7890/default/recommendations?person=p1&action=likes'
```

To compact the database

```
curl -X POST 'http://localhost:7890/default/compact'
```

#Namespace

Namespaces are exclusive places to store events and query for recommendations

To create a custom namespace

```
curl -X POST 'http://localhost:7890/namespace/movies'
```


Then you can add events

```
curl -X POST 'http://localhost:7890/movies/event' -d '{person: "p1", action: "likes", thing: "x-men"}'
```


A namespace also has an individual GER configuration which can be set by passing a payload, e.g.

```
curl -X POST 'http://localhost:7890/namespace' -d '{name: "movies", options: {crowd_weight: 1}}'
```

Delete a namespace (and all its events) with 

```
curl -X DELETE 'http://localhost:7890/namespace/movies'
```
