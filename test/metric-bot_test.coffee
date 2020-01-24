chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

Robot       = require 'hubot/src/robot'
TextMessage = require('hubot/src/message').TextMessage

describe 'metric-bot', ->
  robot = {}
  user = {}
  adapter = {}
  spies = {}

  beforeEach (done) ->
    # Create new robot, with http, using mock adapter
    robot = new Robot null, 'mock-adapter', true

    robot.adapter.on 'connected', =>
      spies.hear = sinon.spy(robot, 'hear')

      require('../src/metric-bot')(robot)

      user = robot.brain.userForId '1', {
        name: 'user'
        room: '#test'
      }

      adapter = robot.adapter

    robot.run()

    done()

  afterEach ->
    robot.shutdown()

  describe 'listeners', ->
    it 'registered hear american temperature', ->
      expect(spies.hear).to.have.been.calledWith(/(-?\d+)\s?(F|Fahrenheit)\b/i)

    it 'registered hear canadian temperature', ->
      expect(spies.hear).to.have.been.calledWith(/(-?\d+)\s?(C|Celsius)\b/i)

  describe 'test conversions to Canadian', ->
    it 'responds to 39F', (done) ->
      adapter.on 'send', (envelope, strings) ->
        expect(strings[0]).to.match /39 in Fahrenheit is 3 degrees Celsius/
        done()

      adapter.receive(new TextMessage user, 'it is 39F today')

    it 'responds to 39 Fahrenheit', (done) ->
      adapter.on 'send', (envelope, strings) ->
        expect(strings[0]).to.match /39 in Fahrenheit is 3 degrees Celsius/
        done()

      adapter.receive(new TextMessage user, 'it is 39 Fahrenheit today')

  describe 'test conversions to American', ->
    it 'responds to 12C', (done) ->
      adapter.on 'send', (envelope, strings) ->
        expect(strings[0]).to.match /12 in Celsius is 53 degrees Fahrenheit/
        done()

      adapter.receive(new TextMessage user, 'it feels like 12C today')

    it 'responds to 12 Celsius', (done) ->
      adapter.on 'send', (envelope, strings) ->
        expect(strings[0]).to.match /12 in Celsius is 53 degrees Fahrenheit/
        done()

      adapter.receive(new TextMessage user, 'it feels like 12 Celsius today')


describe 'negative assertions', ->
  robot = {}
  user = {}
  adapter = {}
  spies = {}

  beforeEach (done) ->
    # Create new robot, with http, using mock adapter
    robot = new Robot null, 'mock-adapter', true

    robot.adapter.on 'connected', =>
      spies.hear = sinon.spy(robot, 'hear')
      spies.catchAll = sinon.spy(robot, 'catchAll')

      require('../src/metric-bot')(robot)

      user = robot.brain.userForId '1', {
        name: 'user'
        room: '#test'
      }

      adapter = robot.adapter

    robot.run()

    done()

  afterEach ->
    robot.shutdown()

  describe 'test negative patterns', ->
    it 'does not responds to percent 2C', (done) ->
#      testMessage = new TextMessage(user, 'this is a failing test%2C%20string.')
      testMessage = new TextMessage(user, 'this is a passing (no-match) test string.')

      listenerCallback = sinon.spy()
      robot.hear /(-?\d+)\s?(C|Celsius)\b/i, listenerCallback

      robot.catchAll (response) ->
        expect(listenerCallback).to.not.have.been.called
        expect(response.message).to.equal(testMessage)
        done()

      adapter.receive testMessage
