module.exports = (robot) ->

  tempFtoC = (tempF) ->
    Math.floor((tempF - 32) * (5 / 9))

  tempCtoF = (tempC) ->
    Math.floor((9 * tempC / 5) + 32)

  temperatureEmoji = (tempF) ->
    switch
      when tempF <= 32 then ":snowflake:"
      when tempF < 80 then ":sun_behind_cloud:"
      else ":fire:"

  robot.hear /(?:^|[\s,.;!?—–()])((minus |-)?\d+)\s?(F|Fahrenheit)([\s,.;!?—–()]|$)/i, (res) ->
    tempF = res.match[1].replace('minus ', '-');
    tempC = tempFtoC(tempF)
    res.send "If you can't read 'Murican, #{tempF} in Fahrenheit is #{tempC} degrees Celsius #{temperatureEmoji(tempF)}"

  robot.hear /(?:^|[\s,.;!?—–()])((minus |-)?\d+)\s?(C|Celsius)([\s,.;!?—–()]|$)/i, (res) ->
    tempC = res.match[1].replace('minus ', '-');
    tempF = tempCtoF(tempC)
    res.send "If you live in Liberia, Myanmar or other countries that use the imperial " +
        "system, #{tempC} in Celsius is #{tempF} degrees Fahrenheit #{temperatureEmoji(tempF)}"
