app = angular.module("app")

app.factory "Timeframe", ["$http", ($http)->
  class Timeframe
    constructor: (opts)->
      defaultOpts =
        started: null
        ended: null
        client: null
      _this = this
      useOpts = _.extend defaultOpts, opts
      _.each useOpts, (val, key) ->
        _this[key] = val

    calcTotal: (ratePerSecond)->
      if ratePerSecond && @started && @ended
        @durationSeconds() * ratePerSecond
      else
        0
    durationSeconds: ->
      (@ended - @started) / 1000

    setEndedNow: ->
      @ended = new Date()

    setStartedNow: ->
      @started = new Date()

    checkForIssues: ->
      issues = []
      # TimeFrame more than 10 hours.
      tenHours = 3600 * 10
      if @started && @ended && @durationSeconds() >= tenHours
        issues.push "Duration is longer than 10 hours. Please double-check."
      if @started && @ended && @durationSeconds() < 0
        issues.push "Duration is smaller 0. Please check."
      issues

    issueDetected: ->
      @checkForIssues().length > 0

  Timeframe
]
