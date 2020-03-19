module.exports = (robot) ->

  units = [
    {
      symbol: 'F'
      name: 'Fahrenheit'
      matchers: [ 'F', 'Fahrenheit', 'Farenheit' ]
      reason: 'If you live in Liberia, Myanmar or other countries that use the imperial system'
      to:
        C: (degrees) -> Math.floor((degrees - 32) * (5 / 9))
        K: (degrees) -> Math.floor((degrees + 459.67) * (5 / 9))
      getEmoji: (degrees) ->
        switch
          when degrees <= 32 then ":snowflake:"
          when degrees < 80 then ":sun_behind_cloud:"
          else ":fire:"
    },
    {
      symbol: 'C'
      name: 'Celsius'
      matchers: [ 'C', 'Celsius', 'Centigrade' ]
      reason: "If you can't read 'Murican"
      to:
        F: (degrees) -> Math.floor((9 * degrees / 5) + 32)
        K: (degrees) -> Math.floor(degrees + 273.15)
      getEmoji: (degrees) ->
        switch
          when degrees <= 0 then ":snowflake:"
          when degrees < 26 then ":sun_behind_cloud:"
          else ":fire:"
    },
    {
      symbol: 'K'
      name: 'kelvin'
      matchers: [ 'K', 'Kelvin', 'kelvin' ]
      reason: 'If you\'re a quantum mechanic'
      to:
        C: (degrees) -> degrees - 273.15
        F: (degrees) -> degrees * (9 / 5) - 459.67
      getEmoji: (degrees) -> ""
    },
    {
      symbol: 'mi'
      name: 'miles'
      matchers: [ 'mile', 'miles', 'mi' ]
      reason: 'If you live in Liberia, Myanmar or other countries that use the imperial system'
      to:
        km: (n) -> n * 1.609344
      getEmoji: (n) -> ""
    },
    {
      symbol: 'km'
      name: 'kilometers'
      matchers: [ 'kilometer', 'kilometers', 'km' ]
      reason: "If you can't read 'Murican"
      to:
        mi: (n) -> n / 1.609344
      getEmoji: (n) -> ""
    }
  ]

  negationTokens = 'negative |minus |-'
  number = "(?:#{negationTokens})?\\d+(?:\\.\\d+)?"
  unitTokens = units.flatMap( (unit) -> unit.matchers).join('|')

  # respond when someone asks to convert between two units specifically
  robot.hear new RegExp("(?:convert)?\\s*(?:from)?\\s*(#{number})°?\\s?(#{unitTokens}) to (#{unitTokens})\\b", 'i'), (res) ->
    fromUnit = units.find (unit) -> unit.matchers.includes(res.match[2])
    toUnit = units.find (unit) -> unit.matchers.includes(res.match[3])
    fromDegrees = +res.match[1].replace(new RegExp(negationTokens, 'i'), '-')
    if (fromUnit.to[toUnit.symbol] == undefined)
      return res.send "Sorry, I don't know how to convert #{fromUnit.name} to #{toUnit.name}"
    toDegrees = fromUnit.to[toUnit.symbol](fromDegrees)
    res.send "#{fromDegrees} #{fromUnit.name} is #{toDegrees} #{toUnit.name}"

  # fuzzier matching when someone just mentions an amount
  robot.hear new RegExp("(?:^|[\\s,.;!?—–()])(#{number})°?\\s?(#{unitTokens})([\\s,.;!?—–()]|$)", 'i'), (res) ->
    fromUnit = units.find (unit) -> unit.matchers.includes(res.match[2])
    toUnit = units.find (unit) -> unit.to[fromUnit.symbol] # a conversion function exists
    fromDegrees = +res.match[1].replace(new RegExp(negationTokens, 'i'), '-')
    toDegrees = fromUnit.to[toUnit.symbol](fromDegrees)
    res.send "#{toUnit.reason}, #{fromDegrees} #{fromUnit.name} is #{toDegrees} #{toUnit.name} #{toUnit.getEmoji(toDegrees)}"
