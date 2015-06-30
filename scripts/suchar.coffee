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


new_suchars = (robot, res, max_id) ->
  console.log 'new_suchars', max_id

  query = {
    screen_name: 'suchardnia',
    count: 200
  }

  if max_id
    query.max_id = max_id
  else
    robot.brain.set 'suchary', {tweets: []}

  tweets_brain = robot.brain.get 'suchary'

  client.get 'statuses/user_timeline', query, (error, tweets, response) ->
    new_max_id = -1

    for tweet in tweets
      tweets_brain.tweets.push tweet
      if new_max_id == -1
        new_max_id = tweet.id

      new_max_id = tweet.id if tweet.id < new_max_id

    if new_max_id > -1 && (!max_id || (max_id > new_max_id))
      new_suchars robot, res, new_max_id
    else
      robot.brain.set 'suchary', tweets_brain
      res.reply "Downloaded #{tweets_brain.tweets.length} suchars!"


module.exports = (robot) ->
  robot.hear /^nowe suchary$/, (res) ->
    #client.get 'statuses/user_timeline', {screen_name: 'suchardnia', count: 200}, (error, tweets, response) ->
    #  robot.brain.set 'suchary', {tweets: tweets}
    #  res.reply "Downloaded #{tweets.length} suchars!"
    new_suchars robot, res, null

  robot.hear /^suchar$/, (res) ->
    suchary = robot.brain.get 'suchary'
    console.log suchary.tweets.length
    tweet = suchary.tweets[Math.floor(Math.random() * suchary.tweets.length)]
    res.reply tweet.text
