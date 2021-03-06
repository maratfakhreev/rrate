Moment = require('moment')

class Timer
  INTERVAL = 1000
  EVENT_DATE = '2015-01-07'

  constructor: ($timerSelector) ->
    @$days = $timerSelector.find('.days .count')
    @$hours = $timerSelector.find('.hours .count')
    @$minutes = $timerSelector.find('.minutes .count')
    @$seconds = $timerSelector.find('.seconds .count')

    @_timer()

  _timer: ->
    currentTime = Moment()
    eventTime = Moment(EVENT_DATE)
    diffTime = eventTime - currentTime
    duration = Moment.duration(diffTime, 'milliseconds')

    setInterval(=>
      duration = Moment.duration(duration - INTERVAL, 'milliseconds')
      @$days.html(@_format(duration.days()))
      @$hours.html(@_format(duration.hours()))
      @$minutes.html(@_format(duration.minutes()))
      @$seconds.html(@_format(duration.seconds()))
    , INTERVAL)

  _format: (number) ->
    if number < 10 then "0#{number}" else "#{number}"

module.exports = Timer
