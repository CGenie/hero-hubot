child_process = require('child_process')

module.exports = (robot) ->
    robot.hear /^cal( me)?$/i, (res) ->
        child_process.exec 'cal', (error, stdout, stderr) ->
            res.send(stdout)
