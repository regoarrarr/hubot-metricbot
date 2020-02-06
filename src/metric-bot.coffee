module.exports = (robot) ->

  units = [
    {
      symbol: 'F'
      name: 'Fahrenheit'
      matchers: [ 'F', 'Fahrenheit', 'Farenheit' ]
      condition: "If you can't read 'Murican"
      to:
        C: (degrees) -> Math.floor((degrees - 32) * (5 / 9))
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
      condition: 'If you live in Liberia, Myanmar or other countries that use the imperial system'
      to:
        F: (degrees) -> Math.floor((9 * degrees / 5) + 32)
      getEmoji: (degrees) ->
        switch
          when degrees <= 0 then ":snowflake:"
          when degrees < 26 then ":sun_behind_cloud:"
          else ":fire:"
    }
  ]

  unitTokens = units.flatMap( (unit) -> unit.matchers).join('|')
  matcher = new RegExp("(?:^|[\\s,.;!?—–()])((?:minus |-)?\\d+)°?\\s?(#{unitTokens})([\\s,.;!?—–()]|$)")

  robot.hear matcher, (res) ->
    fromUnit = units.find (unit) -> unit.matchers.includes(res.match[2])
    toUnit = units.find (unit) -> unit != fromUnit # this is silly
    fromDegrees = +res.match[1].replace(/minus /i, '-')
    toDegrees = fromUnit.to[toUnit.symbol](fromDegrees)
    res.send "#{fromUnit.condition}, #{fromDegrees} in #{fromUnit.name} is #{toDegrees} degrees #{toUnit.name} #{toUnit.getEmoji(toDegrees)}"
