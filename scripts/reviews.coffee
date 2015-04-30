# Description:
#   OpenStack Gerrit reviews support
#
# Notes:
#   https://review.openstack.org/#/c/xxx/ -- display info about review number xxx
#   bugs <username> -- display info about open bugs of user <username>
#   all bugs <username> -- display info about all bugs of user <username>


ReviewNumberURLRegex = /http.*?review\.openstack\.org\/.*?(\d+)/

# gerrit is strange, sends )]}' on first line
stripGerritShit = (shit) -> shit[4..]

URLHelpers =
  gerrit:
    reviewNumberFromURL: (url) ->
      match = (url || '').match(ReviewNumberURLRegex)

      return match && match[1]
  gerritAPI:
    review: (reviewNumber) -> "https://review.openstack.org/changes/#{reviewNumber}/"
    reviewers: (reviewNumber) -> "https://review.openstack.org/changes/#{reviewNumber}/reviewers/"

showReviewInfo = (robot, res, reviewNumber) ->
  console.log('reviewNumber', reviewNumber)
  robot.http(URLHelpers.gerritAPI.review(reviewNumber)).get() (e, r, b) ->
    console.log(e)
    console.log(b)

    reviewInfo = JSON.parse(stripGerritShit(b))

    robot.http(URLHelpers.gerritAPI.reviewers(reviewNumber)).get() (er, rr, br) ->
      reviewers = JSON.parse(stripGerritShit(br))

      rs = for reviewer in reviewers
        #approvals = [reviewer.approvals['Code-Review'], reviewer.approvals['Verified']]
        console.log(reviewer.name, reviewer.approvals)
        approvals = for k, v of reviewer.approvals
          if parseInt(v) != 0
            if k == 'Code-Review' then v else "#{k}: #{v}"
          else
            null
        approvals = (a for a in approvals when a)
        if approvals.length then ("#{reviewer.name} " + approvals.join(" ")) else null

      msg = '```'
      msg += "Review #{reviewNumber} :: #{reviewInfo.subject} [#{reviewInfo.owner.name}]\n"
      msg += "project :: #{reviewInfo.project}   topic :: #{reviewInfo.topic}   status :: #{reviewInfo.status}\n"
      msg += "ChangeID :: #{reviewInfo.change_id}\n"
      msg += (r for r in rs when r).join(" :: ")
      msg += '```'

      res.reply msg


module.exports = (robot) ->
  robot.hear RegExp(ReviewNumberURLRegex.source, 'g'), (res) ->
    console.log(res.match)
    (showReviewInfo(robot, res, URLHelpers.gerrit.reviewNumberFromURL(url)) for url in res.match)
#
#  # https://launchpad.net/bugs/XXXX
#  # https://bugs.launchpad.net/fuel/+bug/XXXX
#
#  robot.hear /https?:\/\/.*?launchpad\.net.*?\/\+?bugs?\/(\d+)/g, (res) ->
#    console.log(res.match)
#    (showBugInfo(robot, res, URLHelpers.launchpadApi.bugNumberFromURL(bugLink)) for bugLink in res.match)

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
