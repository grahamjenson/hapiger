describe 'GET recommendations', ->
  it 'should 404 for no namespace' , ->
    start_server
    .then( ->
      client = new GERClient("#{server.info.uri}","NOTnamespace")
      client.recommendations_for_person("person", "action")
    )
    .spread( (json, status) ->
      status.should.equal 404
    )

  it ' returns recommendations for a person action', ->
    client = null
    start_server_w_client().then( (cli) -> client = cli)
    .then( ->
      client.recommendations_for_person("person", "action")
    )
    .spread( (json, status) ->
      status.should.equal 200
      json.recommendations.length.should.equal 0
    )

  it 'return simple recommendations for a person action', ->
    client = null
    start_server_w_client().then( (cli) -> client = cli)
    .then( ->
      requests.all_200([
        client.action( "buy", 1)
        client.action( "view", 1)
        client.event( "p1", "buy", "a")
        client.event( "p1", "view", "b")
        client.event( "p2", "view", "b")
      ])
    )
    .then( ->
      client.recommendations_for_person("p2", "buy")
    )
    .spread( (json, status) ->
      status.should.equal 200
      json.recommendations.length.should.equal 1
      json.recommendations[0].thing.should.equal 'a'
    )


describe 'POST Events', ->
  it 'should 404 for no namespace' , ->
    start_server
    .then( ->
      client = new GERClient("#{server.info.uri}","NOTnamespace")
      client.event("person", "action", "thing")
    )
    .spread( (json, status) ->
      status.should.equal 404
    )

  it 'create event for namespace', ->
    client = null
    start_server_w_client().then( (cli) -> client = cli)
    .then( ->
      client.event("person", "action", "thing")
    )
    .spread( (json, status) ->
      status.should.equal 200
      json.event.person.should.equal "person"
      json.event.action.should.equal "action"
      json.event.thing.should.equal "thing"
    )


  it 'should return 400 when you dont pass a thing', ->
    client = null
    start_server_w_client().then( (cli) -> client = cli)
    .then( ->
      client.event("person", "action")
    )
    .spread( (json, status) ->
      status.should.equal 400
    )


describe 'GET event', ->
  it 'should 404 if no events for action thing are found', ->
    client = null
    start_server_w_client().then( (cli) -> client = cli)
    .then( ->
      client.get_event(undefined, 'action', 'thing')
    )
    .spread( (json, status) ->
      status.should.equal 404
    )

  it 'should return 404 if the event does not exist', ->
    client = null
    start_server_w_client().then( (cli) -> client = cli)
    .then( ->
      client.get_event("person", 'action', 'thing')
    )
    .spread( (json, status) ->
      status.should.equal 404
    )

  it 'should return 200 event if the event exists', ->
    client = null
    start_server_w_client().then( (cli) -> client = cli)
    .then( ->
      client.event("p" , "a", "t")
    )
    .spread( (json, status) ->
      status.should.equal 200
      client.event('p', 'a', 't')
    )
    .spread( (json, status) ->
      status.should.equal 200
      json.event.person.should.equal 'p'
      json.event.action.should.equal 'a'
      json.event.thing.should.equal 't'
    )


describe 'POST compact', ->
  it 'should remove duplicate events' , ->
    client = null
    start_server_w_client().then( (cli) -> client = cli)
    .then( ->
      s = 'p,q,t,2014-01-01,\n'
      s+= 'p,q,t,2014-01-01,\n'
      s+= 'p,q,t,2014-01-01,\n'

      client.bootstrap(new Buffer(s))
    )
    .spread( (json, status) ->
      status.should.equal 200
      json.added_events.should.equal 3
      client.compact_database()
    )
    .spread( (json, status) ->
      status.should.equal 200
      json.end_count.should.equal 1
      client.get_event_stats()
    )
    .spread( (json, status) ->
      status.should.equal 200
      json.count.should.equal 1
    )
