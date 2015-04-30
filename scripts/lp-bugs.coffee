# Description:
#   Launchpad integration
#
# Notes:
#   #XXX -- display info about bug number XXX
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

APIDomain = 'api.launchpad.net'
LaunchpadAPIUrl = 'https://' + APIDomain + '/1.0/'
LaunchpadUrl = 'https://launchpad.net/'


# https://launchpad.net/bugs/XXXX
# https://bugs.launchpad.net/fuel/+bug/XXXX
LPBugRegexp = /https?:\/\/.*?launchpad\.net.*?\/\+?bugs?\/(\d+)/

URLHelpers =
  launchpad:
    bug: (bugNumber) -> LaunchpadUrl + 'bugs/' + bugNumber
    project: (name) -> LaunchpadUrl + name
    user: (username) -> LaunchpadUrl + '~' + username
  launchpadApi:
    bug: (bugNumber) -> LaunchpadAPIUrl + 'bugs/' + bugNumber
    user: (username) -> LaunchpadAPIUrl + '~' + username
    userBugTasks: (username) ->
      url = URLHelpers.launchpadApi.user(username)

      return url + "?ws.op=searchTasks&assignee=" + encodeURIComponent(url)
    bugNumberFromURL: (url) ->
      match = (url || '').match(LPBugRegexp)

      return match && match[1]

    milestoneFromURL: (url) ->
      s = url.split('/')

      return s[s.length - 1]

    userFromURL: (url) ->
      return 'NONE' if not url

      s = url.split('/')

      return s[s.length - 1].replace('~', '')

showBugInfo = (robot, res, bugNumber) ->
  robot.http(URLHelpers.launchpadApi.bug(bugNumber)).get() (e, r, b) ->
    #console.log(e)
    #console.log(b)

    bugInfo = JSON.parse(b)

    #console.log(bugInfo.bug_tasks_collection_link)

    robot.http(bugInfo.bug_tasks_collection_link).get() (ebt, rbt, bbt) ->
      bugTasks = JSON.parse(bbt)

      formatEntry = (entry) -> '[' + 'milesetone :: ' + URLHelpers.launchpadApi.milestoneFromURL(entry.milestone_link) + ', ' +
        'status :: ' + entry.status + ', ' +
        'assignee :: ' + URLHelpers.launchpadApi.userFromURL(entry.assignee_link) + ', ' +
        'importance :: ' + entry.importance + ']'

      priorities = (formatEntry(entry) for entry in bugTasks.entries)
      msg = '```'
      msg += 'Bug ' + bugNumber + ' :: ' + bugInfo.title  + '\n'
      msg += priorities.join('\n') + '\n'
      msg += URLHelpers.launchpad.bug(bugNumber)
      msg += '```'

      res.reply msg


module.exports = (robot) ->
  robot.hear /\#(\d+)/g, (res) ->
    (showBugInfo(robot, res, bugNumber.replace('#', '')) for bugNumber in res.match)

  robot.hear RegExp(LPBugRegexp.source, 'g'), (res) ->
    (showBugInfo(robot, res, URLHelpers.launchpadApi.bugNumberFromURL(bugLink)) for bugLink in res.match)

  robot.respond /bugs (.*)/, (res) ->
    username = res.match[1]
    console.log('bugs', username)

    robot.http(URLHelpers.launchpadApi.userBugTasks(username)).get() (e, r, b) ->
      bugTasks = JSON.parse(b)

      (showBugInfo(robot, res, URLHelpers.launchpadApi.bugNumberFromURL(bugTask.bug_link)) for bugTask in bugTasks.entries when bugTask.status == 'In Progress')

  robot.respond /all bugs (.*)/, (res) ->
    username = res.match[1]
    console.log('all bugs', username)

    robot.http(URLHelpers.launchpadApi.userBugTasks(username)).get() (e, r, b) ->
      bugTasks = JSON.parse(b)

      (showBugInfo(robot, res, URLHelpers.launchpadApi.bugNumberFromURL(bugTask.bug_link)) for bugTask in bugTasks.entries)


  # robot.hear /badger/i, (res) ->
  #   res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  # robot.respond /open the (.*) doors/i, (res) ->
  #   doorType = res.match[1]
  #   if doorType is "pod bay"
  #     res.reply "I'm afraid I can't let you do that."
  #   else
  #     res.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (res) ->
  #   res.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'
