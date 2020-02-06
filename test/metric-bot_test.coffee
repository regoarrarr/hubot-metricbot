assert = require 'assert'

Robot       = require 'hubot/src/robot'
TextMessage = require('hubot/src/message').TextMessage

describe 'definitions', ->
  robot = {}

  beforeEach ->
    # Create new robot, with http, using mock adapter
    robot = new Robot null, 'mock-adapter', true
    robot.adapter.on 'connected', ->
      require('../src/metric-bot')(robot)
    robot.run()

  afterEach ->
    robot.shutdown()

  # (async) Resolves to hubots first reply to a given message, or rejects if no reply is made within the timeout
  reply = (message) ->
    return Promise.race [
      new Promise((resolve, reject) -> setTimeout((() -> reject('No reply')), 500)),
      new Promise((resolve, reject) ->
        robot.adapter.on 'send', (envelope, strings) -> resolve(strings[0])
        robot.adapter.receive(new TextMessage {}, message)
      )
    ]

  describe 'test conversions to Canadian', ->
    it 'responds to 39F', ->
      assert.match await reply('it is 39F today'), /39 in Fahrenheit is 3 degrees Celsius/
    it 'responds to 39 Fahrenheit', ->
      assert.match await reply('it is 39 Fahrenheit today'), /39 in Fahrenheit is 3 degrees Celsius/

  describe 'test conversions to American', ->
    it 'responds to 12C', ->
      assert.match await reply('hubot: it feels like 12C today'), /12 in Celsius is 53 degrees Fahrenheit/
    it 'responds to 12 Celsius', ->
      assert.match await reply('hubot: it feels like 12 Celsius today'), /12 in Celsius is 53 degrees Fahrenheit/

  describe 'test conversions to American', ->
    it 'responds to 12C', ->
      assert.match await reply('hubot: it feels like 12C today'), /12 in Celsius is 53 degrees Fahrenheit/
    it 'responds to 12 Celsius', ->
      assert.match await reply('hubot: it feels like 12 Celsius today'), /12 in Celsius is 53 degrees Fahrenheit/

  describe 'test negation', ->
    it 'minus', ->
      assert.match await reply('hubot: it feels like -12C today'), /-12 in Celsius is 10 degrees Fahrenheit/
    it 'minus sign', ->
      assert.match await reply('hubot: it feels like minus 12 Celsius today'), /-12 in Celsius is 10 degrees Fahrenheit/

  describe 'test degree sign', ->
    it 'there can be a degree sign immediately after the number of degrees', ->
      assert.match await reply('hubot: it feels like -12°C today'), /-12 in Celsius is 10 degrees Fahrenheit/

  describe 'test spam prevention', ->
    it 'ignores URLs', ->
      assert.rejects reply('hubot: https://docs.sonatype.com/display/LRN/Improvement+Day+-+Session+72+-+February+6%2C+2020')
    it 'ignores commit hashes', ->
      assert.rejects reply('hubot: 231596cbb5f0321ab77e6f22a558aa8f988fe43d')
    it 'ignores the World Wide Web Consortium', ->
      assert.rejects reply('hubot: I <3 the W3C')
