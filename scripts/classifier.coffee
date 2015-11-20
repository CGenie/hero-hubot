# Description:
#   Classifier API client
#

CLASSIFIER_URL = process.env.CLASSIFIER_URL || 'http://localhost:8080/api'
BUCKET_ROOMS = 'hubot-rooms'
BUCKET_USERS = 'hubot-users'
BUCKETS = [BUCKET_ROOMS, BUCKET_USERS]
WHATS = (bucket.replace('hubot-', '') for bucket in BUCKETS).join(', ')


module.exports = (robot) ->
  robot.hear /.*/, (msg) ->
    text = msg.match[0]
    if text.indexOf('hubot') == 0
      return
    room = msg.message.room
    url = "#{CLASSIFIER_URL}/train/#{BUCKET_ROOMS}/#{room}"
    data = JSON.stringify {text: text}
    msg.robot.http(url).header('Content-Type', 'application/json').post(data)
    user = msg.message.user.name
    url = "#{CLASSIFIER_URL}/train/#{BUCKET_USERS}/#{user}"
    msg.robot.http(url).header('Content-Type', 'application/json').post(data)

  robot.respond /classify (\w+) (.*)/, (msg) ->
    what = msg.match[1]
    text = msg.match[2]
    bucket = "hubot-#{what}"
    if BUCKETS.indexOf(bucket) == -1
      msg.send "Unknown classificator #{what}, pick one of: #{WHATS}"
      return
    url = "#{CLASSIFIER_URL}/classify/#{bucket}"
    data = JSON.stringify {text: text}
    msg.robot.http(url).header('Content-Type', 'application/json').post(data) (err, res, body) ->
      msg.send body

  robot.respond /classifier-similarity (\w+) (\w+) (\w+)/, (msg) ->
    what = msg.match[1]
    category1 = msg.match[2]
    category2 = msg.match[3]
    bucket = "hubot-#{what}"
    if BUCKETS.indexOf(bucket) == -1
      msg.send "Unknown classificator #{what}, pick one of: #{WHATS}"
      return
    url = "#{CLASSIFIER_URL}/similarity/#{bucket}/#{category1}/#{category2}"
    msg.robot.http(url).header('Content-Type', 'application/json').get() (err, res, body) ->
      msg.send body

  robot.respond /classifier-delete-all/, (msg) ->
    for bucket in BUCKETS
      url = "#{CLASSIFIER_URL}/classify/#{bucket}"
      msg.robot.http(url).delete() (err, res, body) ->
        msg.send "Deleted all classifications in bucket #{bucket}"

  robot.respond /classifier-debug (\w+) (.*)/, (msg) ->
    what = msg.match[1]
    category = msg.match[2]
    bucket = "hubot-#{what}"
    if BUCKETS.indexOf(bucket) == -1
      msg.send "Unknown classificator #{what}, pick one of: #{WHATS}"
      return
    url = "#{CLASSIFIER_URL}/debug/#{bucket}/#{category}"
    msg.robot.http(url).get() (err, res, body) ->
      msg.send body
