chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'
chaiFiles = require 'chai-files'
chai.use chaiFiles

expect = chai.expect
file = chaiFiles.file

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
