{Adapter} = require 'hubot'

class MockAdapter extends Adapter
  run: -> @emit 'connected'
  close: -> @emit 'closed'
  send: ->
  emote: ->
  reply: ->
  topic: ->
  play: ->

module.exports.use = (robot) ->
  new MockAdapter(robot)
