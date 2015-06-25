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
  robot.hear /^suchar$/g, (res) ->
    client.get 'statuses/user_timeline', {screen_name: 'suchardnia'}, (error, tweets, response) ->
      tweet = tweets[Math.floor(Math.random() * tweets.length)]
      res.reply tweet.text
