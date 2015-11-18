# Description:
#   Classifier API client
#

CLASSIFIER_URL = process.env.CLASSIFIER_URL || 'http://localhost:8080/api'
BUCKET = 'hubot-rooms'


module.exports = (robot) ->
  robot.hear /.*/, (msg) ->
    text = msg.match[0]
    if text.indexOf('hubot') == 0
      return
    #user = msg.user.name
    room = msg.message.room
    url = "#{CLASSIFIER_URL}/train/#{BUCKET}/#{room}"
    data = JSON.stringify {text: text}
    msg.robot.http(url).header('Content-Type', 'application/json').post(data)

  robot.respond /classify (.*)/, (msg) ->
    text = msg.match[1]
    room = msg.message.room
    url = "#{CLASSIFIER_URL}/classify/#{BUCKET}"
    data = JSON.stringify {text: text}
    msg.robot.http(url).header('Content-Type', 'application/json').post(data) (err, res, body) ->
      msg.send body
