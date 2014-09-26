# Description:
#   Enables hubot to suggest commands when not found.
#
# The function looks like this:
#
# Hubot> hubot youtobe me penguin
# Hubot> Could not find command 'hubot youtobe me penguin'.
# Maybe you meant 'Hubot youtube me' or 'Hubot time' or 'Hubot the rules'.
# Run `Hubot help` for more commands.
#
# Author:
#   hassaku
#

# Private: Calculate amount of difference between two commands
#
# Returns the distance value
levenshtein = (str1, str2) ->
  l1 = str1.length
  l2 = str2.length
  dist = []

  return l2 unless l1
  return l1 unless l2

  dist[i] = [i] for i in [0..l1]
  dist[0][j] = j for j in [1..l2]

  for i in [1..l1]
    for j in [1..l2]
      if str1[i-1] is str2[j-1]
        dist[i][j] = dist[i-1][j-1]
      else
        dist[i][j] = Math.min(dist[i-1][j], dist[i][j-1], dist[i-1][j-1]) + 1
  dist[l1][l2]

# Private: Show suggestions inferred from input
#
# Returns nothing.
showSuggestions = (examples, input, adapter, name) ->
  inputCommand = input.text.split(" ")[1]
  return unless inputCommand

  suggestions = []

  for example in examples
    exampleCommand = example.replace /[-<].*$/, ''
    continue if exampleCommand.match("^hubot *$") or not exampleCommand.match("^hubot")
    command = exampleCommand.split(" ")[1]
    continue unless command
    distance = levenshtein(inputCommand, command)
    suggestions.push { command: "'#{exampleCommand.trim()}'", distance: distance }

  if suggestions.length
    suggestions = suggestions.sort (a, b) -> a.distance - b.distance
    messages = """
    Could not find command '#{input.text}'.
    Maybe you meant #{(suggestions[0..2].map (s) -> s.command.replace /hubot/, name).join(' or ')}.
    Run `#{name} help` for more commands.
    """
    adapter.send input.user, messages

module.exports = (robot) ->
  robot.catchAll (msg) ->
    message = msg.message
    showSuggestions(robot.commands, message, robot.adapter, robot.name) if message.text.match ///^#{robot.name} .*$///i
    msg.finish()
