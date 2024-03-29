# Description:
#   Track arbitrary karma
#   Fork of hubot-karma-classic
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   <thing>++ - give thing some karma
#   hubot karma <thing> - check thing's karma (if <thing> is omitted, show the top 5)
#   hubot karma empty <thing> - empty a thing's karma
#   hubot karma best [n] - show the top n (default: 5)
#   hubot karma worst [n] - show the bottom n (default: 5)
#
# Author:
#   D. Stuart Freeman (@stuartf) https://github.com/stuartf
#   Andy Beger (@abeger) https://github.com/abeger
#
# BD Changes by:
#   Tim Erickson (@stpaultim) https://github.com/stpaultim


class Karma

  constructor: (@robot) ->
    @cache = {}

    @increment_responses = [
        "1000%", "great work", "thanks for all you do", 
        "leveled up!", "go team.", "- Dragon Fire", "kudos", 
        "GG", "Cheers", "Props to you for all your hard work.",
        ":-)", ":grinning:  :heart:", ":drop_lounging: :drop_lounging: :drop_lounging: :drop_lounging:",
        ":pancakes:"
    ]

    @decrement_responses = [
      "took a hit! Ouch.", "took a dive.", "- oops! Sorry about that.", "really?", "????", 
      "peanuts and brittle.", "didn't see that coming"
    ]

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.karma
        @cache = @robot.brain.data.karma

  kill: (thing) ->
    delete @cache[thing]
    @robot.brain.data.karma = @cache

  increment: (thing) ->
    @cache[thing] ?= 0
    @cache[thing] += 1
    @robot.brain.data.karma = @cache

  decrement: (thing) ->
    @cache[thing] ?= 0
    @cache[thing] -= 1
    @robot.brain.data.karma = @cache

  incrementResponse: ->
    @increment_responses[Math.floor(Math.random() * @increment_responses.length)]

  decrementResponse: ->
    @decrement_responses[Math.floor(Math.random() * @decrement_responses.length)]

  get: (thing) ->
    k = if @cache[thing] then @cache[thing] else 0
    return k

  sort: ->
    s = []
    for key, val of @cache
      s.push({ name: key, karma: val })
    s.sort (a, b) -> b.karma - a.karma

  top: (n = 5) =>
    sorted = @sort()
    sorted.slice(0, n)

  bottom: (n = 5) =>
    sorted = @sort()
    sorted.slice(-n).reverse()

module.exports = (robot) ->
  karma = new Karma robot

  ###
  # Listen for "++" messages and increment
  ###
  robot.hear /@?(\S+[^+\s])\s*\+\+(\s|$)/, (msg) ->
    subject = msg.match[1].toLowerCase()
    karma.increment subject
    msg.send "#{subject} #{karma.incrementResponse()} (Karma: #{karma.get(subject)})"

  ###
  # Listen for "--" messages and decrement
  ###

  ## We find this annoying for Backdrop, so I'm turning this off.

  #  robot.hear /@?(\S+[^-\s])\s*--(\s|$)/, (msg) ->
  #    subject = msg.match[1].toLowerCase()
  #    # avoid catching HTML comments
  #    unless subject[-2..] == "<!"
  #      karma.decrement subject
  #    msg.send "#{subject} #{karma.decrementResponse()} (Karma: #{karma.get(subject)})"

  ###
  # Listen for "karma empty x" and empty x's karma
  ###
  robot.respond /karma empty ?(\S+[^-\s])$/i, (msg) ->
    subject = msg.match[1].toLowerCase()
    karma.kill subject
    msg.send "#{subject} has had its karma scattered to the winds."

  ###
  # Function that handles best and worst list
  # @param msg The message to be parsed
  # @param title The title of the list to be returned
  # @param rankingFunction The function to call to get the ranking list
  ###
  parseListMessage = (msg, title, rankingFunction) ->
    count = if msg.match.length > 1 then msg.match[1] else null
    verbiage = [title]
    if count?
      verbiage[0] = verbiage[0].concat(" ", count.toString())
    for item, rank in rankingFunction(count)
      verbiage.push "#{rank + 1}. #{item.name} - #{item.karma}"
    msg.send verbiage.join("\n")

  ###
  # Listen for "karma best [n]" and return the top n rankings
  ###
  robot.respond /karma best\s*(\d+)?$/i, (msg) ->
    parseData = parseListMessage(msg, "The Best", karma.top)

  ###
  # Listen for "karma worst [n]" and return the bottom n rankings
  ###
  robot.respond /karma worst\s*(\d+)?$/i, (msg) ->
    parseData = parseListMessage(msg, "The Worst", karma.bottom)

  ###
  # Listen for "karma x" and return karma for x
  ###
  robot.respond /karma (\S+[^-\s])$/i, (msg) ->
    match = msg.match[1].toLowerCase()
    if not (match in ["best", "worst"])
      msg.send "\"#{match}\" has #{karma.get(match)} karma."

