Helper = require('hubot-test-helper')
expect = require('chai').expect
sinon = require('sinon')

helper = new Helper('./../scripts/suggest.coffee')

describe 'suggest', ->
  room = null
  COMMANDS = ["hubot youtube", "hubot ping"]

  beforeEach ->
    room = helper.createRoom()

  afterEach ->
    room.destroy()

  context 'user says typoed ping command to hubot', ->
    beforeEach ->
      sinon.sandbox.stub room.robot, "commands", (command + " some args" for command in COMMANDS)
      room.user.say 'alice', 'hubot peng'

    it 'should suggest ping command at first', ->
      expect(room.messages[0][1]).to.eql 'hubot peng'
      expect(room.messages[1][1]).to.match /Maybe you meant \'hubot ping/

  context 'user says typoed youtube command to hubot', ->
    beforeEach ->
      sinon.sandbox.stub room.robot, "commands", (command + " some args" for command in COMMANDS)
      room.user.say 'alice', 'hubot youtoob'

    it 'should suggest youtube command at first', ->
      expect(room.messages[0][1]).to.eql 'hubot youtoob'
      expect(room.messages[1][1]).to.match /Maybe you meant \'hubot youtube/

