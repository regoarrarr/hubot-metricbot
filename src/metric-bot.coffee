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
      ignoreMentions: true
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

  explicitConvertMatcher = new RegExp("(?:convert)?\\s*(?:from)?\\s*(#{number})°?\\s?(#{unitTokens}) to (#{unitTokens})\\b", 'i')
  mentionedUnitMatcher = new RegExp("(?:^|[\\s,.;!?—–()])(#{number})°?\\s?(#{unitTokens})([\\s,.;!?—–()]|$)", 'i')
  negationMatcher = new RegExp(negationTokens, 'i')

  # parse and convert from text strings
  # amount and fromUnitToken are required; if toUnitToken isn't provided, defaults to the first unit that's convertible
  convert = (fromAmountString, fromUnitString, toUnitString) ->
    fromAmount = +fromAmountString.replace(negationMatcher, '-')
    fromUnit = units.find (unit) -> unit.matchers.find (matcher) -> matcher.toLowerCase() == fromUnitString.toLowerCase()
    toUnit = if toUnitString
      units.find (unit) -> unit.matchers.find (matcher) -> matcher.toLowerCase() == toUnitString.toLowerCase()
    else
      toUnit = units.find (unit) -> unit.to[fromUnit.symbol]
    toAmount = if fromUnit and toUnit and fromUnit.to[toUnit.symbol]
      fromUnit.to[toUnit.symbol](fromAmount)
    else
      null
    return { fromAmount, fromUnit, toAmount, toUnit }

  # Listen for any unit we know about, then see if it's an explicit command like "convert 0°C to F" or just a mention, like "I biked 20km"
  robot.hear new RegExp("#{unitTokens}\\b", 'i'), (res) ->
    explicitMatch = explicitConvertMatcher.exec(res.match.input);
    if (explicitMatch)
      { fromAmount, fromUnit, toAmount, toUnit } = convert(explicitMatch[1], explicitMatch[2], explicitMatch[3])
      if toAmount == null
        return res.send "Sorry, I don't know how to convert #{fromUnit.name} to #{toUnit.name}"
      return res.send "#{fromAmount} #{fromUnit.name} is #{toAmount} #{toUnit.name}"
    mentionMatch = mentionedUnitMatcher.exec(res.match.input)
    if (mentionMatch)
      { fromAmount, fromUnit, toAmount, toUnit } = convert(mentionMatch[1], mentionMatch[2], null)
      if (fromUnit.ignoreMentions)
        return
      if fromAmount != null and fromUnit and toAmount != null and toUnit
        return res.send "#{toUnit.reason}, #{fromAmount} #{fromUnit.name} is #{toAmount} #{toUnit.name} #{toUnit.getEmoji(toAmount)}"
