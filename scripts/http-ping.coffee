# Description:
#    Respond with hubot status (for monitoring)
#
# URLS:
#    GET /hubot/status

module.exports = (robot) ->
    robot.router.get '/hubot/status', (req, res) ->
        res.send JSON.stringify({message: 'ok'})
