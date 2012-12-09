Posts = new Meteor.Collection 'posts'

if Meteor.isClient

  Meteor.subscribe 'posts'

  #Setup Template
  Template.posts.posts = ->
    Posts.find {}, {sort: ['date', 'desc']}

  # Setup form event
  Template.form.events
    'submit form': (e) ->
      title = $('#title').val()
      body = $('#body').val()
      Posts.insert({title: title, body: body, time: Date.now()})
      Meteor.call('savePost', title, body)
      Meteor.call('loadPosts')
      $('form')[0].reset()
      e.preventDefault()

  Template.posts.events
    'click .delete': (e) ->
      Posts.remove({dbid: @.dbid})
      Meteor.call('removePost', @.dbid)
      Meteor.call('loadPosts')
      e.preventDefault()      

if Meteor.isServer

  Meteor.publish 'posts', ->
    Posts.find {}, {limit: 5}

  # Save post to Polytalk
  savePost = (title, body) ->

    saveRequest =
      class: 'Post'
      method: 'create'
      arguments:
        args:
          title: title
          body: body

    
    client.call saveRequest, (response) ->
      console.log(response)

    return true

  
  # Remove post from Polytalk
  removePost = (id) ->

    deleteRequest =
      class: 'Post'
      method: 'destroy'
      arguments:
        id: id

    client.call deleteRequest, (response) ->
      console.log(response)

    return true

  # Load posts from Polytalk
  loadPosts = ->

    # Remove all posts from collection
    Posts.remove({})

    postsRequest =
      class: 'Post'
      method: 'find'
      arguments:
        type: ':all'
        options:
          order: 'id DESC'
          limit: 10

    client.call postsRequest, (response) ->
      posts = response.map (post) -> post.post
      for post in posts
        Fiber ->
          Posts.insert({dbid: post.id, title: post.title, body: post.body, time: Date.now()})
        .run()

    return true

  Meteor.methods
    savePost: savePost
    loadPosts: loadPosts
    removePost: removePost

  Meteor.startup ->
    loadPosts()
