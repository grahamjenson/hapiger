describe 'GET recommendations', ->
  it 'should 404 for no namespace' , ->
    client = null
    start_server
    .then( ->
      client = new GERClient("#{server.info.uri}", "new_namespace")
      client.show_namespace("person", "action")
    )
    .spread( (json, status) ->
      status.should.equal 404
    )

  it 'should be able to create namespace' , ->
    client = null
    start_server
    .then( ->
      client = new GERClient("#{server.info.uri}", "new_namespace")
      client.show_namespace("person", "action")
    )
    .spread( (json, status) ->
      status.should.equal 404
      client.create_namespace()
    )
    .spread( (json, status) ->
      status.should.equal 200
      client.show_namespace()
    )
    .spread( (json, status) ->
      status.should.equal 200
    )