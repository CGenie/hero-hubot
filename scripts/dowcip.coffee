# Description:
#   http://perelki.net integration
#
# Commands:
#   dowcip -- random dowcip

cheerio = require 'cheerio'

URL = 'http://perelki.net/one.php'
MAX_ID = 6000


get_dowcip = (msg) ->
    iid = Math.floor(Math.random() * MAX_ID)
    robot.http(URL).query(id: iid).get() (err, res, body) ->
      page = cheerio.load body, normalizeWhitespace: true
      el = page 'div.content div.container'

      if el.length == 0
        console.log "No text for #{iid}"
        return get_dowcip msg

      msg.reply el.text()


module.exports = (robot) ->
  robot.hear /^dowcip$/, (msg) ->
    get_dowcip msg
