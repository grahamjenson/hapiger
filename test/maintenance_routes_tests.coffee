describe 'maintenance routes', ->
  describe 'POST compact', ->
    it 'should work', ->
      ns = random_namespace()
      start_server
      .then( ->
        client.create_namespace(ns)
      )
      .then( ->
        client.create_compact(ns)
      )
      .spread( (body, resp) ->
        console.log body
      )

    it 'should 404 on bad namespace', ->
      ns = random_namespace()
      start_server
      .then( ->
        client.create_compact(ns)
      )
      .then( ->
        throw "SHOULD NOT GET HERE"
      )
      .catch(GERClient.Not200Error, (e) ->
        e.status.should.equal 404
      )