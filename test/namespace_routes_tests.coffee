describe "namespace routes", ->

  describe "POST namespaces", ->
    it 'should work', ->
      ns = random_namespace()
      start_server
      .then( ->
        client.create_namespace(ns)
      )
      .then( ->
        client.show_namespaces()
      )
      .spread( (body, resp) ->
        body.namespaces.should.include ns
      )

  describe "GET namespaces", ->
    it 'should list existing namespaces', ->
      ns = random_namespace()
      start_server
      .then( ->
        client.create_namespace(ns)
      )
      .then( ->
        client.show_namespaces()
      )
      .spread( (body, resp) ->
        body.namespaces.should.include ns
      )

  describe "DELETE namespaces", ->
    it 'should 404 if namespace does not exist', ->
      ns = random_namespace()
      start_server
      .then( ->
        client.destroy_namespace(ns)
      )
      .then( ->
        throw "SHOULD NOT GET HERE"
      )
      .catch(GERClient.Not200Error, (e) ->
        e.status.should.equal 404
      )


    it 'should remove ns from existing namespaces', ->
      ns = random_namespace()
      start_server
      .then( ->
        client.create_namespace(ns)
      )
      .then( ->
        client.show_namespaces()
      )
      .spread( (body, resp) ->
        body.namespaces.should.include ns
        client.destroy_namespace(ns)
      )
      .then( ->
        client.show_namespaces()
      )
      .spread( (body, resp) ->
        body.namespaces.should.not.include ns
      )
