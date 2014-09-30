{Robot, User, TextMessage} = require 'hubot'
assert = require 'power-assert'
path = require 'path'
sinon = require 'sinon'

describe 'twada', ->
  beforeEach (done) ->
    @sinon = sinon.sandbox.create()
    # for warning: possible EventEmitter memory leak detected.
    # process.on 'uncaughtException'
    @sinon.stub process, 'on', -> null
    @robot = new Robot(path.resolve(__dirname, '..'), 'shell', false, 'hubot')
    @robot.adapter.on 'connected', =>
      @robot.load path.resolve(__dirname, '../../src/scripts')
      setTimeout done, 10 # wait for parseHelp()
    @robot.run()

  afterEach (done) ->
    @robot.brain.on 'close', =>
      @sinon.restore()
      done()
    @robot.shutdown()

  describe 'listeners[0].regex', ->
    describe 'valid patterns', ->
      beforeEach ->
        @tests = [
          message: 'テスト書いてない'
          matches: ['テスト書いてない', 'テスト書いてない']
        ,
          message: 'テスト書いていない'
          matches: ['テスト書いていない', 'テスト書いていない']
        ,
          message: 'テストを書いてない'
          matches: ['テストを書いてない', 'テストを書いてない']
        ,
          message: 'テストは書いてない'
          matches: ['テストは書いてない', 'テストは書いてない']
        ,
          message: 'テスト書きたくない'
          matches: ['テスト書きたくない', 'テスト書きたくない']
        ,
          message: 'test書いてない'
          matches: ['test書いてない', 'test書いてない']
        ]

      it 'should match', ->
        @tests.forEach ({ message, matches }) =>
          callback = @sinon.spy()
          @robot.listeners[0].callback = callback
          sender = new User 'bouzuya', room: 'hitoridokusho'
          @robot.adapter.receive new TextMessage(sender, message)
          actualMatches = callback.firstCall.args[0].match.map((i) -> i)
          assert callback.callCount is 1
          assert.deepEqual actualMatches, matches

  describe 'listeners[0].callback', ->
    beforeEach ->
      @twada = @robot.listeners[0].callback

    describe 'receive "テスト書いてない"', ->
      beforeEach ->
        @send = @sinon.spy()
        @twada
          match: ['テスト書いてない', 'テスト書いてない']
          send: @send

      it '''
send "テスト書いてないとかお前それ @t_wada の前でも同じこと言えんの？"
         ''', ->
        assert @send.callCount is 1
        assert @send.firstCall.args[0] is \
          'テスト書いてないとかお前それ @t_wada の前でも同じこと言えんの？'

    describe 'receive "テスト書きたくない"', ->
      beforeEach ->
        @send = @sinon.spy()
        @twada
          match: ['テスト書きたくない', 'テスト書きたくない']
          send: @send

      it '''
send "テスト書きたくないとかお前それ @t_wada の前でも同じこと言えんの？"
         ''', ->
        assert @send.callCount is 1
        assert @send.firstCall.args[0] is \
          'テスト書きたくないとかお前それ @t_wada の前でも同じこと言えんの？'

  describe 'robot.helpCommands()', ->
    it 'should be ["テスト書いてない - returns a t_wada.png"]', ->
      assert.deepEqual @robot.helpCommands(), [
        "テスト書いてない - returns a t_wada.png"
      ]
