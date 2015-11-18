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
    room = msg.message.room
    url = "#{CLASSIFIER_URL}/train/#{BUCKET}/#{room}"
    data = JSON.stringify {text: text}
    msg.robot.http(url).header('Content-Type', 'application/json').post(data)

  robot.respond /classify (.*)/, (msg) ->
    text = msg.match[1]
    url = "#{CLASSIFIER_URL}/classify/#{BUCKET}"
    data = JSON.stringify {text: text}
    msg.robot.http(url).header('Content-Type', 'application/json').post(data) (err, res, body) ->
      msg.send body

  robot.respond /classifier-delete-all/, (msg) ->
    url = "#{CLASSIFIER_URL}/classify/#{BUCKET}"
    msg.robot.http(url).delete() (err, res, body) ->
      msg.send "Deleted all classifications in bucket #{BUCKET}"

  robot.respond /classifier-debug (.*)/, (msg) ->
    room = msg.match[1]
    url = "#{CLASSIFIER_URL}/debug/#{BUCKET}/#{room}"
    msg.robot.http(url).get() (err, res, body) ->
      msg.send body
