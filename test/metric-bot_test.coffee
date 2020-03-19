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

  describe 'test simple conversion', ->
    it 'converts F to C', ->
      assert.match await reply('hubot: Convert -40° F to C'), /-40 Fahrenheit is -40 Celsius/
    it 'converts Celsius to kelvin', -> # note: SI units are lowercase
      assert.match await reply('hubot: convert -40 Celsius to kelvin'), /-40 Celsius is 233 kelvin/
    it 'converts miles to kilometers', ->
      assert.match await reply('hubot: convert 100 miles to kilometers'), /100 miles is 160.9\d* kilometers/i
    it 'apologizes when no conversion function is defined', ->
      assert.match await reply('hubot: convert 0 kelvin to kelvin'), /sorry/i

  describe 'test conversions to Canadian', ->
    it 'responds to 39F', ->
      assert.match await reply('it is 39F today'), /39 Fahrenheit is 3 Celsius/
    it 'responds to 39 Fahrenheit', ->
      assert.match await reply('it is 39 Fahrenheit today'), /39 Fahrenheit is 3 Celsius/
    it 'responds to 500 miles', ->
      assert.match await reply('I would walk 500 miles'), /500 miles is 804.6\d* kilometers/

  describe 'test conversions to American', ->
    it 'responds to 12C', ->
      assert.match await reply('hubot: it feels like 12C today'), /12 Celsius is 53 Fahrenheit/
    it 'responds to 12 Celsius', ->
      assert.match await reply('hubot: it feels like 12 Celsius today'), /12 Celsius is 53 Fahrenheit/

  describe 'test conversions to American', ->
    it 'responds to 12C', ->
      assert.match await reply('hubot: it feels like 12C today'), /12 Celsius is 53 Fahrenheit/
    it 'responds to 12 Celsius', ->
      assert.match await reply('hubot: it feels like 12 Celsius today'), /12 Celsius is 53 Fahrenheit/

  describe 'test negation', ->
    it 'minus', ->
      assert.match await reply('hubot: it feels like -12C today'), /-12 Celsius is 10 Fahrenheit/
    it 'minus sign', ->
      assert.match await reply('hubot: it feels like minus 12 Celsius today'), /-12 Celsius is 10 Fahrenheit/
    it 'negative', ->
      assert.match await reply('hubot: it feels like negative 12 Celsius today'), /-12 Celsius is 10 Fahrenheit/

  describe 'test degree sign', ->
    it 'there can be a degree sign immediately after the number of degrees', ->
      assert.match await reply('hubot: it feels like -12°C today'), /-12 Celsius is 10 Fahrenheit/

  describe 'test spam prevention', ->
    it 'ignores URLs', ->
      assert.rejects reply('hubot: https://docs.sonatype.com/display/LRN/Improvement+Day+-+Session+72+-+February+6%2C+2020')
    it 'ignores commit hashes', ->
      assert.rejects reply('hubot: 231596cbb5f0321ab77e6f22a558aa8f988fe43d')
    it 'ignores the World Wide Web Consortium', ->
      assert.rejects reply('hubot: I <3 the W3C')

  describe 'test decimal point', ->
    it 'there can be a decimal point in the number', ->
      assert.match await reply('hubot: -459.67°F to K'), /-459.67 Fahrenheit is 0 kelvin/

  describe 'test kelvin', ->
    it 'it converts Kelvin correctly', ->
      assert.match await reply('hubot: 0 kelvin to F'), /0 kelvin is -459.67 Fahrenheit/
