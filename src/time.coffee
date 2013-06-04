###
@version: 1.0 Alpha-1
@author: Coolite Inc. http://www.coolite.com/
@date: 2008-04-13
@copyright: Copyright (c) 2006-2008, Coolite Inc. (http://www.coolite.com/). All rights reserved.
@license: Licensed under The MIT License. See license.txt and http://www.datejs.com/license/.
@website: http://www.datejs.com/
###

#
# * TimeSpan(milliseconds);
# * TimeSpan(days, hours, minutes, seconds);
# * TimeSpan(days, hours, minutes, seconds, milliseconds);
#
TimeSpan = (days, hours, minutes, seconds, milliseconds) ->
  attrs = "days hours minutes seconds milliseconds".split(/\s+/)
  gFn = (attr) ->
    ->
      this[attr]

  sFn = (attr) ->
    (val) ->
      this[attr] = val
      this

  i = 0

  while i < attrs.length
    $a = attrs[i]
    $b = $a.slice(0, 1).toUpperCase() + $a.slice(1)
    TimeSpan::[$a] = 0
    TimeSpan::["get" + $b] = gFn($a)
    TimeSpan::["set" + $b] = sFn($a)
    i++
  if arguments.length is 4
    @setDays days
    @setHours hours
    @setMinutes minutes
    @setSeconds seconds
  else if arguments.length is 5
    @setDays days
    @setHours hours
    @setMinutes minutes
    @setSeconds seconds
    @setMilliseconds milliseconds
  else if arguments.length is 1 and typeof days is "number"
    orient = (if (days < 0) then -1 else +1)
    @setMilliseconds Math.abs(days)
    @setDays Math.floor(@getMilliseconds() / 86400000) * orient
    @setMilliseconds @getMilliseconds() % 86400000
    @setHours Math.floor(@getMilliseconds() / 3600000) * orient
    @setMilliseconds @getMilliseconds() % 3600000
    @setMinutes Math.floor(@getMilliseconds() / 60000) * orient
    @setMilliseconds @getMilliseconds() % 60000
    @setSeconds Math.floor(@getMilliseconds() / 1000) * orient
    @setMilliseconds @getMilliseconds() % 1000
    @setMilliseconds @getMilliseconds() * orient
  @getTotalMilliseconds = ->
    (@getDays() * 86400000) + (@getHours() * 3600000) + (@getMinutes() * 60000) + (@getSeconds() * 1000)

  @compareTo = (time) ->
    t1 = new Date(1970, 1, 1, @getHours(), @getMinutes(), @getSeconds())
    t2 = undefined
    if time is null
      t2 = new Date(1970, 1, 1, 0, 0, 0)
    else
      t2 = new Date(1970, 1, 1, time.getHours(), time.getMinutes(), time.getSeconds())
    (if (t1 < t2) then -1 else (if (t1 > t2) then 1 else 0))

  @equals = (time) ->
    @compareTo(time) is 0

  @add = (time) ->
    (if (time is null) then this else @addSeconds(time.getTotalMilliseconds() / 1000))

  @subtract = (time) ->
    (if (time is null) then this else @addSeconds(-time.getTotalMilliseconds() / 1000))

  @addDays = (n) ->
    new TimeSpan(@getTotalMilliseconds() + (n * 86400000))

  @addHours = (n) ->
    new TimeSpan(@getTotalMilliseconds() + (n * 3600000))

  @addMinutes = (n) ->
    new TimeSpan(@getTotalMilliseconds() + (n * 60000))

  @addSeconds = (n) ->
    new TimeSpan(@getTotalMilliseconds() + (n * 1000))

  @addMilliseconds = (n) ->
    new TimeSpan(@getTotalMilliseconds() + n)

  @get12HourHour = ->
    (if (@getHours() > 12) then @getHours() - 12 else (if (@getHours() is 0) then 12 else @getHours()))

  @getDesignator = ->
    (if (@getHours() < 12) then Date.CultureInfo.amDesignator else Date.CultureInfo.pmDesignator)

  @toString = (format) ->
    @_toString = ->
      if @getDays() isnt null and @getDays() > 0
        @getDays() + "." + @getHours() + ":" + @p(@getMinutes()) + ":" + @p(@getSeconds())
      else
        @getHours() + ":" + @p(@getMinutes()) + ":" + @p(@getSeconds())

    @p = (s) ->
      (if (s.toString().length < 2) then "0" + s else s)

    me = this
    (if format then format.replace(/dd?|HH?|hh?|mm?|ss?|tt?/g, (format) ->
      switch format
        when "d"
          me.getDays()
        when "dd"
          me.p me.getDays()
        when "H"
          me.getHours()
        when "HH"
          me.p me.getHours()
        when "h"
          me.get12HourHour()
        when "hh"
          me.p me.get12HourHour()
        when "m"
          me.getMinutes()
        when "mm"
          me.p me.getMinutes()
        when "s"
          me.getSeconds()
        when "ss"
          me.p me.getSeconds()
        when "t"
          ((if (me.getHours() < 12) then Date.CultureInfo.amDesignator else Date.CultureInfo.pmDesignator)).substring 0, 1
        when "tt"
          (if (me.getHours() < 12) then Date.CultureInfo.amDesignator else Date.CultureInfo.pmDesignator)
    ) else @_toString())

  this


###
Gets the time of day for this date instances.
@return {TimeSpan} TimeSpan
###
Date::getTimeOfDay = ->
  new TimeSpan(0, @getHours(), @getMinutes(), @getSeconds(), @getMilliseconds())


#
# * TimePeriod(startDate, endDate);
# * TimePeriod(years, months, days, hours, minutes, seconds, milliseconds);
#
TimePeriod = (years, months, days, hours, minutes, seconds, milliseconds) ->
  attrs = "years months days hours minutes seconds milliseconds".split(/\s+/)
  gFn = (attr) ->
    ->
      this[attr]

  sFn = (attr) ->
    (val) ->
      this[attr] = val
      this

  i = 0

  while i < attrs.length
    $a = attrs[i]
    $b = $a.slice(0, 1).toUpperCase() + $a.slice(1)
    TimePeriod::[$a] = 0
    TimePeriod::["get" + $b] = gFn($a)
    TimePeriod::["set" + $b] = sFn($a)
    i++
  if arguments.length is 7
    @years = years
    @months = months
    @setDays days
    @setHours hours
    @setMinutes minutes
    @setSeconds seconds
    @setMilliseconds milliseconds
  else if arguments.length is 2 and arguments[0] instanceof Date and arguments[1] instanceof Date

    # startDate and endDate as arguments
    d1 = years.clone()
    d2 = months.clone()
    temp = d1.clone()
    orient = (if (d1 > d2) then -1 else +1)
    @years = d2.getFullYear() - d1.getFullYear()
    temp.addYears @years
    if orient is +1
      @years--  if @years isnt 0  if temp > d2
    else
      @years++  if @years isnt 0  if temp < d2
    d1.addYears @years
    if orient is +1
      while d1 < d2 and d1.clone().addDays(Date.getDaysInMonth(d1.getYear(), d1.getMonth())) < d2
        d1.addMonths 1
        @months++
    else
      while d1 > d2 and d1.clone().addDays(Date.getDaysInMonth(d1.getYear(), d1.getMonth())) < d2
        d1.addMonths -1
        @months--
    diff = d2 - d1
    if diff isnt 0
      ts = new TimeSpan(diff)
      @setDays ts.getDays()
      @setHours ts.getHours()
      @setMinutes ts.getMinutes()
      @setSeconds ts.getSeconds()
      @setMilliseconds ts.getMilliseconds()
  this
