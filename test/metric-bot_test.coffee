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

      adapter.receive(new TextMessage user, 'hubot: it feels like 12C today')

    it 'responds to 12 Celsius', (done) ->
      adapter.on 'send', (envelope, strings) ->
        expect(strings[0]).to.match /12 in Celsius is 53 degrees Fahrenheit/
        done()

      adapter.receive(new TextMessage user, 'hubot: it feels like 12 Celsius today')
