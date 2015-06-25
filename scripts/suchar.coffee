# Description:
#   Suchardnia.pl integration
#
# Notes:
#   suchar -- random suchar

consumer_key = process.env.TWITTER_CONSUMER_KEY
consumer_secret = process.env.TWITTER_CONSUMER_SECRET
access_token = process.env.TWITTER_ACCESS_TOKEN
access_token_secret = process.env.TWITTER_ACCESS_TOKEN_SECRET


Twitter = require 'twitter'

client = new Twitter {
  consumer_key: consumer_key,
  consumer_secret: consumer_secret,
  access_token_key: access_token,
  access_token_secret: access_token_secret
}


module.exports = (robot) ->
  robot.hear /^nowe suchary$/, (res) ->
    client.get 'statuses/user_timeline', {screen_name: 'suchardnia', count: 200}, (error, tweets, response) ->
      robot.brain.set 'suchary', {tweets: tweets}
      res.reply 'Downloaded!'

  robot.hear /^suchar$/, (res) ->
    suchary = robot.brain.get 'suchary'
    console.log suchary.tweets.length
    tweet = suchary.tweets[Math.floor(Math.random() * suchary.tweets.length)]
    res.reply tweet.text
