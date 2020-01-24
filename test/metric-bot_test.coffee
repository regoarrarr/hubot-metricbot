chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

Robot       = require 'hubot/src/robot'
TextMessage = require('hubot/src/message').TextMessage

describe 'definitions', ->
  robot = {}
  user = {}
  adapter = {}
  spies = {}

  beforeEach (done) ->
    # Create new robot, with http, using mock adapter
    robot = new Robot null, 'mock-adapter', true

    robot.adapter.on 'connected', =>
      spies.hear = sinon.spy(robot, 'hear')
      spies.respond = sinon.spy(robot, 'respond')

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

  describe 'test conversion to Celsius', ->
    it 'responds to 39F', (done) ->
      adapter.on 'send', (envelope, strings) ->
        expect(strings[0]).to.match /39 in Fahrenheit is 3 degrees Celsius/
        done()

      adapter.receive(new TextMessage user, 'it is 39F today')

  describe 'test conversion to Fahrenheit', ->
    it 'responds to 12C', (done) ->
      adapter.on 'send', (envelope, strings) ->
        expect(strings[0]).to.match /12 in Celsius is 53 degrees Fahrenheit/
        done()

      adapter.receive(new TextMessage user, 'hubot: it feels like 12C today')

