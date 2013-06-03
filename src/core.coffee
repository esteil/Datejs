###
@version: 1.0 Alpha-1
@author: Coolite Inc. http://www.coolite.com/
@date: 2008-04-13
@copyright: Copyright (c) 2006-2008, Coolite Inc. (http://www.coolite.com/). All rights reserved.
@license: Licensed under The MIT License. See license.txt and http://www.datejs.com/license/.
@website: http://www.datejs.com/
###
(->
  $D = Date
  $P = $D::
  p = (s, l) ->
    l = 2  unless l
    ("000" + s).slice l * -1


  ###
  Resets the time of this Date object to 12:00 AM (00:00), which is the start of the day.
  @param {Boolean}  .clone() this date instance before clearing Time
  @return {Date}    this
  ###
  $P.clearTime = ->
    @setHours 0
    @setMinutes 0
    @setSeconds 0
    @setMilliseconds 0
    this


  ###
  Resets the time of this Date object to the current time ('now').
  @return {Date}    this
  ###
  $P.setTimeToNow = ->
    n = new Date()
    @setHours n.getHours()
    @setMinutes n.getMinutes()
    @setSeconds n.getSeconds()
    @setMilliseconds n.getMilliseconds()
    this


  ###
  Gets a date that is set to the current date. The time is set to the start of the day (00:00 or 12:00 AM).
  @return {Date}    The current date.
  ###
  $D.today = ->
    new Date().clearTime()


  ###
  Compares the first date to the second date and returns an number indication of their relative values.
  @param {Date}     First Date object to compare [Required].
  @param {Date}     Second Date object to compare to [Required].
  @return {Number}  -1 = date1 is lessthan date2. 0 = values are equal. 1 = date1 is greaterthan date2.
  ###
  $D.compare = (date1, date2) ->
    if isNaN(date1) or isNaN(date2)
      throw new Error(date1 + " - " + date2)
    else if date1 instanceof Date and date2 instanceof Date
      (if (date1 < date2) then -1 else (if (date1 > date2) then 1 else 0))
    else
      throw new TypeError(date1 + " - " + date2)


  ###
  Compares the first Date object to the second Date object and returns true if they are equal.
  @param {Date}     First Date object to compare [Required]
  @param {Date}     Second Date object to compare to [Required]
  @return {Boolean} true if dates are equal. false if they are not equal.
  ###
  $D.equals = (date1, date2) ->
    date1.compareTo(date2) is 0


  ###
  Gets the day number (0-6) if given a CultureInfo specific string which is a valid dayName, abbreviatedDayName or shortestDayName (two char).
  @param {String}   The name of the day (eg. "Monday, "Mon", "tuesday", "tue", "We", "we").
  @return {Number}  The day number
  ###
  $D.getDayNumberFromName = (name) ->
    $C = @getCultureInfo()
    n = $C.dayNames
    m = $C.abbreviatedDayNames
    o = $C.shortestDayNames
    s = name.toLowerCase()
    i = 0

    while i < n.length
      return i  if n[i].toLowerCase() is s or m[i].toLowerCase() is s or o[i].toLowerCase() is s
      i++
    -1


  ###
  Gets the month number (0-11) if given a Culture Info specific string which is a valid monthName or abbreviatedMonthName.
  @param {String}   The name of the month (eg. "February, "Feb", "october", "oct").
  @return {Number}  The day number
  ###
  $D.getMonthNumberFromName = (name) ->
    $C = @getCultureInfo()
    n = $C.monthNames
    m = $C.abbreviatedMonthNames
    s = name.toLowerCase()
    i = 0

    while i < n.length
      return i  if n[i].toLowerCase() is s or m[i].toLowerCase() is s
      i++
    -1


  ###
  Determines if the current date instance is within a LeapYear.
  @param {Number}   The year.
  @return {Boolean} true if date is within a LeapYear, otherwise false.
  ###
  $D.isLeapYear = (year) ->
    (year % 4 is 0 and year % 100 isnt 0) or year % 400 is 0


  ###
  Gets the number of days in the month, given a year and month value. Automatically corrects for LeapYear.
  @param {Number}   The year.
  @param {Number}   The month (0-11).
  @return {Number}  The number of days in the month.
  ###
  $D.getDaysInMonth = (year, month) ->
    [31, ((if $D.isLeapYear(year) then 29 else 28)), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month]

  $D.getTimezoneAbbreviation = (offset) ->
    $C = @getCultureInfo()
    z = $C.timezones
    p = undefined
    i = 0

    while i < z.length
      return z[i].name  if z[i].offset is offset
      i++
    null

  $D.getTimezoneOffset = (name) ->
    $C = @getCultureInfo()
    z = $C.timezones
    p = undefined
    i = 0

    while i < z.length
      return z[i].offset  if z[i].name is name.toUpperCase()
      i++
    null


  ###
  Returns a new Date object that is an exact date and time copy of the original instance.
  @return {Date}    A new Date instance
  ###
  $P.clone = ->
    new Date(@getTime())


  ###
  Compares this instance to a Date object and returns an number indication of their relative values.
  @param {Date}     Date object to compare [Required]
  @return {Number}  -1 = this is lessthan date. 0 = values are equal. 1 = this is greaterthan date.
  ###
  $P.compareTo = (date) ->
    Date.compare this, date


  ###
  Compares this instance to another Date object and returns true if they are equal.
  @param {Date}     Date object to compare. If no date to compare, new Date() [now] is used.
  @return {Boolean} true if dates are equal. false if they are not equal.
  ###
  $P.equals = (date) ->
    Date.equals this, date or new Date()


  ###
  Determines if this instance is between a range of two dates or equal to either the start or end dates.
  @param {Date}     Start of range [Required]
  @param {Date}     End of range [Required]
  @return {Boolean} true is this is between or equal to the start and end dates, else false
  ###
  $P.between = (start, end) ->
    @getTime() >= start.getTime() and @getTime() <= end.getTime()


  ###
  Determines if this date occurs after the date to compare to.
  @param {Date}     Date object to compare. If no date to compare, new Date() ("now") is used.
  @return {Boolean} true if this date instance is greater than the date to compare to (or "now"), otherwise false.
  ###
  $P.isAfter = (date) ->
    @compareTo(date or new Date()) is 1


  ###
  Determines if this date occurs before the date to compare to.
  @param {Date}     Date object to compare. If no date to compare, new Date() ("now") is used.
  @return {Boolean} true if this date instance is less than the date to compare to (or "now").
  ###
  $P.isBefore = (date) ->
    @compareTo(date or new Date()) is -1


  ###
  Determines if the current Date instance occurs today.
  @return {Boolean} true if this date instance is 'today', otherwise false.
  ###

  ###
  Determines if the current Date instance occurs on the same Date as the supplied 'date'.
  If no 'date' to compare to is provided, the current Date instance is compared to 'today'.
  @param {date}     Date object to compare. If no date to compare, the current Date ("now") is used.
  @return {Boolean} true if this Date instance occurs on the same Day as the supplied 'date'.
  ###
  $P.isToday = $P.isSameDay = (date) ->
    @clone().clearTime().equals (date or new Date()).clone().clearTime()


  ###
  Adds the specified number of milliseconds to this instance.
  @param {Number}   The number of milliseconds to add. The number can be positive or negative [Required]
  @return {Date}    this
  ###
  $P.addMilliseconds = (value) ->
    @setMilliseconds @getMilliseconds() + value * 1
    this


  ###
  Adds the specified number of seconds to this instance.
  @param {Number}   The number of seconds to add. The number can be positive or negative [Required]
  @return {Date}    this
  ###
  $P.addSeconds = (value) ->
    @addMilliseconds value * 1000


  ###
  Adds the specified number of seconds to this instance.
  @param {Number}   The number of seconds to add. The number can be positive or negative [Required]
  @return {Date}    this
  ###
  $P.addMinutes = (value) ->
    @addMilliseconds value * 60000 # 60*1000


  ###
  Adds the specified number of hours to this instance.
  @param {Number}   The number of hours to add. The number can be positive or negative [Required]
  @return {Date}    this
  ###
  $P.addHours = (value) ->
    @addMilliseconds value * 3600000 # 60*60*1000


  ###
  Adds the specified number of days to this instance.
  @param {Number}   The number of days to add. The number can be positive or negative [Required]
  @return {Date}    this
  ###
  $P.addDays = (value) ->
    @setDate @getDate() + value * 1
    this


  ###
  Adds the specified number of weeks to this instance.
  @param {Number}   The number of weeks to add. The number can be positive or negative [Required]
  @return {Date}    this
  ###
  $P.addWeeks = (value) ->
    @addDays value * 7


  ###
  Adds the specified number of months to this instance.
  @param {Number}   The number of months to add. The number can be positive or negative [Required]
  @return {Date}    this
  ###
  $P.addMonths = (value) ->
    n = @getDate()
    @setDate 1
    @setMonth @getMonth() + value * 1
    @setDate Math.min(n, $D.getDaysInMonth(@getFullYear(), @getMonth()))
    this


  ###
  Adds the specified number of years to this instance.
  @param {Number}   The number of years to add. The number can be positive or negative [Required]
  @return {Date}    this
  ###
  $P.addYears = (value) ->
    @addMonths value * 12


  ###
  Adds (or subtracts) to the value of the years, months, weeks, days, hours, minutes, seconds, milliseconds of the date instance using given configuration object. Positive and Negative values allowed.
  Example
  <pre><code>
  Date.today().add( { days: 1, months: 1 } )

  new Date().add( { years: -1 } )
  </code></pre>
  @param {Object}   Configuration object containing attributes (months, days, etc.)
  @return {Date}    this
  ###
  $P.add = (config) ->
    if typeof config is "number"
      @_orient = config
      return this
    x = config
    @addMilliseconds x.milliseconds  if x.milliseconds
    @addSeconds x.seconds  if x.seconds
    @addMinutes x.minutes  if x.minutes
    @addHours x.hours  if x.hours
    @addWeeks x.weeks  if x.weeks
    @addMonths x.months  if x.months
    @addYears x.years  if x.years
    @addDays x.days  if x.days
    this

  $y = undefined
  $m = undefined
  $d = undefined

  ###
  Get the week number. Week one (1) is the week which contains the first Thursday of the year. Monday is considered the first day of the week.
  This algorithm is a JavaScript port of the work presented by Claus T�ndering at http://www.tondering.dk/claus/cal/node8.html#SECTION00880000000000000000
  .getWeek() Algorithm Copyright (c) 2008 Claus Tondering.
  The .getWeek() function does NOT convert the date to UTC. The local datetime is used. Please use .getISOWeek() to get the week of the UTC converted date.
  @return {Number}  1 to 53
  ###
  $P.getWeek = ->
    a = undefined
    b = undefined
    c = undefined
    d = undefined
    e = undefined
    f = undefined
    g = undefined
    n = undefined
    s = undefined
    w = undefined
    $y = (if (not $y) then @getFullYear() else $y)
    $m = (if (not $m) then @getMonth() + 1 else $m)
    $d = (if (not $d) then @getDate() else $d)
    if $m <= 2
      a = $y - 1
      b = (a / 4 | 0) - (a / 100 | 0) + (a / 400 | 0)
      c = ((a - 1) / 4 | 0) - ((a - 1) / 100 | 0) + ((a - 1) / 400 | 0)
      s = b - c
      e = 0
      f = $d - 1 + (31 * ($m - 1))
    else
      a = $y
      b = (a / 4 | 0) - (a / 100 | 0) + (a / 400 | 0)
      c = ((a - 1) / 4 | 0) - ((a - 1) / 100 | 0) + ((a - 1) / 400 | 0)
      s = b - c
      e = s + 1
      f = $d + ((153 * ($m - 3) + 2) / 5) + 58 + s
    g = (a + b) % 7
    d = (f + g - e) % 7
    n = (f + 3 - d) | 0
    if n < 0
      w = 53 - ((g - s) / 5 | 0)
    else if n > 364 + s
      w = 1
    else
      w = (n / 7 | 0) + 1
    $y = $m = $d = null
    w


  ###
  Get the ISO 8601 week number. Week one ("01") is the week which contains the first Thursday of the year. Monday is considered the first day of the week.
  The .getISOWeek() function does convert the date to it's UTC value. Please use .getWeek() to get the week of the local date.
  @return {String}  "01" to "53"
  ###
  $P.getISOWeek = ->
    $y = @getUTCFullYear()
    $m = @getUTCMonth() + 1
    $d = @getUTCDate()
    p @getWeek()


  ###
  Moves the date to Monday of the week set. Week one (1) is the week which contains the first Thursday of the year.
  @param {Number}   A Number (1 to 53) that represents the week of the year.
  @return {Date}    this
  ###
  $P.setWeek = (n) ->
    @moveToDayOfWeek(1).addWeeks n - @getWeek()


  # private
  validate = (n, min, max, name) ->
    if typeof n is "undefined" or not n?
      return false
    else unless typeof n is "number"
      throw new TypeError(n + " is not a Number.")
    else throw new RangeError(n + " is not a valid value for " + name + ".")  if n < min or n > max
    true


  ###
  Validates the number is within an acceptable range for milliseconds [0-999].
  @param {Number}   The number to check if within range.
  @return {Boolean} true if within range, otherwise false.
  ###
  $D.validateMillisecond = (value) ->
    validate value, 0, 999, "millisecond"


  ###
  Validates the number is within an acceptable range for seconds [0-59].
  @param {Number}   The number to check if within range.
  @return {Boolean} true if within range, otherwise false.
  ###
  $D.validateSecond = (value) ->
    validate value, 0, 59, "second"


  ###
  Validates the number is within an acceptable range for minutes [0-59].
  @param {Number}   The number to check if within range.
  @return {Boolean} true if within range, otherwise false.
  ###
  $D.validateMinute = (value) ->
    validate value, 0, 59, "minute"


  ###
  Validates the number is within an acceptable range for hours [0-23].
  @param {Number}   The number to check if within range.
  @return {Boolean} true if within range, otherwise false.
  ###
  $D.validateHour = (value) ->
    validate value, 0, 23, "hour"


  ###
  Validates the number is within an acceptable range for the days in a month [0-MaxDaysInMonth].
  @param {Number}   The number to check if within range.
  @return {Boolean} true if within range, otherwise false.
  ###
  $D.validateDay = (value, year, month) ->
    validate value, 1, $D.getDaysInMonth(year, month), "day"


  ###
  Validates the number is within an acceptable range for months [0-11].
  @param {Number}   The number to check if within range.
  @return {Boolean} true if within range, otherwise false.
  ###
  $D.validateMonth = (value) ->
    validate value, 0, 11, "month"


  ###
  Validates the number is within an acceptable range for years.
  @param {Number}   The number to check if within range.
  @return {Boolean} true if within range, otherwise false.
  ###
  $D.validateYear = (value) ->
    validate value, 0, 9999, "year"


  ###
  Set the value of year, month, day, hour, minute, second, millisecond of date instance using given configuration object.
  Example
  <pre><code>
  Date.today().set( { day: 20, month: 1 } )

  new Date().set( { millisecond: 0 } )
  </code></pre>

  @param {Object}   Configuration object containing attributes (month, day, etc.)
  @return {Date}    this
  ###
  $P.set = (config) ->
    @addMilliseconds config.millisecond - @getMilliseconds()  if $D.validateMillisecond(config.millisecond)
    @addSeconds config.second - @getSeconds()  if $D.validateSecond(config.second)
    @addMinutes config.minute - @getMinutes()  if $D.validateMinute(config.minute)
    @addHours config.hour - @getHours()  if $D.validateHour(config.hour)
    @addMonths config.month - @getMonth()  if $D.validateMonth(config.month)
    @addYears config.year - @getFullYear()  if $D.validateYear(config.year)

    # day has to go last because you can't validate the day without first knowing the month
    @addDays config.day - @getDate()  if $D.validateDay(config.day, @getFullYear(), @getMonth())
    @setTimezone config.timezone  if config.timezone
    @setTimezoneOffset config.timezoneOffset  if config.timezoneOffset
    @setWeek config.week  if config.week and validate(config.week, 0, 53, "week")
    this


  ###
  Moves the date to the first day of the month.
  @return {Date}    this
  ###
  $P.moveToFirstDayOfMonth = ->
    @set day: 1


  ###
  Moves the date to the last day of the month.
  @return {Date}    this
  ###
  $P.moveToLastDayOfMonth = ->
    @set day: $D.getDaysInMonth(@getFullYear(), @getMonth())


  ###
  Moves the date to the next n'th occurrence of the dayOfWeek starting from the beginning of the month. The number (-1) is a magic number and will return the last occurrence of the dayOfWeek in the month.
  @param {Number}   The dayOfWeek to move to
  @param {Number}   The n'th occurrence to move to. Use (-1) to return the last occurrence in the month
  @return {Date}    this
  ###
  $P.moveToNthOccurrence = (dayOfWeek, occurrence) ->
    shift = 0
    if occurrence > 0
      shift = occurrence - 1
    else if occurrence is -1
      @moveToLastDayOfMonth()
      @moveToDayOfWeek dayOfWeek, -1  if @getDay() isnt dayOfWeek
      return this
    @moveToFirstDayOfMonth().addDays(-1).moveToDayOfWeek(dayOfWeek, +1).addWeeks shift


  ###
  Move to the next or last dayOfWeek based on the orient value.
  @param {Number}   The dayOfWeek to move to
  @param {Number}   Forward (+1) or Back (-1). Defaults to +1. [Optional]
  @return {Date}    this
  ###
  $P.moveToDayOfWeek = (dayOfWeek, orient) ->
    diff = (dayOfWeek - @getDay() + 7 * (orient or +1)) % 7
    @addDays (if (diff is 0) then diff += 7 * (orient or +1) else diff)


  ###
  Move to the next or last month based on the orient value.
  @param {Number}   The month to move to. 0 = January, 11 = December
  @param {Number}   Forward (+1) or Back (-1). Defaults to +1. [Optional]
  @return {Date}    this
  ###
  $P.moveToMonth = (month, orient) ->
    diff = (month - @getMonth() + 12 * (orient or +1)) % 12
    @addMonths (if (diff is 0) then diff += 12 * (orient or +1) else diff)


  ###
  Get the Ordinal day (numeric day number) of the year, adjusted for leap year.
  @return {Number} 1 through 365 (366 in leap years)
  ###
  $P.getOrdinalNumber = ->
    Math.ceil((@clone().clearTime() - new Date(@getFullYear(), 0, 1)) / 86400000) + 1


  ###
  Get the time zone abbreviation of the current date.
  @return {String} The abbreviated time zone name (e.g. "EST")
  ###
  $P.getTimezone = ->
    $D.getTimezoneAbbreviation @getUTCOffset()

  $P.setTimezoneOffset = (offset) ->
    here = @getTimezoneOffset()
    there = Number(offset) * -6 / 10
    @addMinutes there - here

  $P.setTimezone = (offset) ->
    @setTimezoneOffset $D.getTimezoneOffset(offset)


  ###
  Indicates whether Daylight Saving Time is observed in the current time zone.
  @return {Boolean} true|false
  ###
  $P.hasDaylightSavingTime = ->
    Date.today().set(
      month: 0
      day: 1
    ).getTimezoneOffset() isnt Date.today().set(
      month: 6
      day: 1
    ).getTimezoneOffset()


  ###
  Indicates whether this Date instance is within the Daylight Saving Time range for the current time zone.
  @return {Boolean} true|false
  ###
  $P.isDaylightSavingTime = ->
    Date.today().set(
      month: 0
      day: 1
    ).getTimezoneOffset() isnt @getTimezoneOffset()


  ###
  Get the offset from UTC of the current date.
  @return {String} The 4-character offset string prefixed with + or - (e.g. "-0500")
  ###
  $P.getUTCOffset = ->
    n = @getTimezoneOffset() * -10 / 6
    r = undefined
    if n < 0
      r = (n - 10000).toString()
      r.charAt(0) + r.substr(2)
    else
      r = (n + 10000).toString()
      "+" + r.substr(1)


  ###
  Returns the number of milliseconds between this date and date.
  @param {Date} Defaults to now
  @return {Number} The diff in milliseconds
  ###
  $P.getElapsed = (date) ->
    (date or new Date()) - this

  unless $P.toISOString

    ###
    Converts the current date instance into a string with an ISO 8601 format. The date is converted to it's UTC value.
    @return {String}  ISO 8601 string of date
    ###
    $P.toISOString = ->

      # From http://www.json.org/json.js. Public Domain.
      f = (n) ->
        (if n < 10 then "0" + n else n)
      h = (i) ->
        (if i.length < 2 then "00" + i else (if i.length < 3 then "0" + i else (if 3 < i.length then Math.round(i / Math.pow(10, i.length - 3)) else i)))
      "\"" + @getUTCFullYear() + "-" + f(@getUTCMonth() + 1) + "-" + f(@getUTCDate()) + "T" + f(@getUTCHours()) + ":" + f(@getUTCMinutes()) + ":" + f(@getUTCSeconds()) + "." + h(@getUTCMilliseconds()) + "Z\""

  # private
  $P._toString = $P.toString

  ###
  Converts the value of the current Date object to its equivalent string representation.
  Format Specifiers
  <pre>
  CUSTOM DATE AND TIME FORMAT STRINGS
  Format  Description                                                                  Example
  ------  ---------------------------------------------------------------------------  -----------------------
  s      The seconds of the minute between 0-59.                                      "0" to "59"
  ss     The seconds of the minute with leading zero if required.                     "00" to "59"

  m      The minute of the hour between 0-59.                                         "0"  or "59"
  mm     The minute of the hour with leading zero if required.                        "00" or "59"

  h      The hour of the day between 1-12.                                            "1"  to "12"
  hh     The hour of the day with leading zero if required.                           "01" to "12"

  H      The hour of the day between 0-23.                                            "0"  to "23"
  HH     The hour of the day with leading zero if required.                           "00" to "23"

  d      The day of the month between 1 and 31.                                       "1"  to "31"
  dd     The day of the month with leading zero if required.                          "01" to "31"
  ddd    Abbreviated day name. $C.abbreviatedDayNames.                                "Mon" to "Sun"
  dddd   The full day name. $C.dayNames.                                              "Monday" to "Sunday"

  M      The month of the year between 1-12.                                          "1" to "12"
  MM     The month of the year with leading zero if required.                         "01" to "12"
  MMM    Abbreviated month name. $C.abbreviatedMonthNames.                            "Jan" to "Dec"
  MMMM   The full month name. $C.monthNames.                                          "January" to "December"

  yy     The year as a two-digit number.                                              "99" or "08"
  yyyy   The full four digit year.                                                    "1999" or "2008"

  t      Displays the first character of the A.M./P.M. designator.                    "A" or "P"
  $C.amDesignator or $C.pmDesignator
  tt     Displays the A.M./P.M. designator.                                           "AM" or "PM"
  $C.amDesignator or $C.pmDesignator

  S      The ordinal suffix ("st, "nd", "rd" or "th") of the current day.            "st, "nd", "rd" or "th"

  || *Format* || *Description* || *Example* ||
  || d      || The CultureInfo shortDate Format Pattern                                     || "M/d/yyyy" ||
  || D      || The CultureInfo longDate Format Pattern                                      || "dddd, MMMM dd, yyyy" ||
  || F      || The CultureInfo fullDateTime Format Pattern                                  || "dddd, MMMM dd, yyyy h:mm:ss tt" ||
  || m      || The CultureInfo monthDay Format Pattern                                      || "MMMM dd" ||
  || r      || The CultureInfo rfc1123 Format Pattern                                       || "ddd, dd MMM yyyy HH:mm:ss GMT" ||
  || s      || The CultureInfo sortableDateTime Format Pattern                              || "yyyy-MM-ddTHH:mm:ss" ||
  || t      || The CultureInfo shortTime Format Pattern                                     || "h:mm tt" ||
  || T      || The CultureInfo longTime Format Pattern                                      || "h:mm:ss tt" ||
  || u      || The CultureInfo universalSortableDateTime Format Pattern                     || "yyyy-MM-dd HH:mm:ssZ" ||
  || y      || The CultureInfo yearMonth Format Pattern                                     || "MMMM, yyyy" ||


  STANDARD DATE AND TIME FORMAT STRINGS
  Format  Description                                                                  Example ("en-US")
  ------  ---------------------------------------------------------------------------  -----------------------
  d      The CultureInfo shortDate Format Pattern                                     "M/d/yyyy"
  D      The CultureInfo longDate Format Pattern                                      "dddd, MMMM dd, yyyy"
  F      The CultureInfo fullDateTime Format Pattern                                  "dddd, MMMM dd, yyyy h:mm:ss tt"
  m      The CultureInfo monthDay Format Pattern                                      "MMMM dd"
  r      The CultureInfo rfc1123 Format Pattern                                       "ddd, dd MMM yyyy HH:mm:ss GMT"
  s      The CultureInfo sortableDateTime Format Pattern                              "yyyy-MM-ddTHH:mm:ss"
  t      The CultureInfo shortTime Format Pattern                                     "h:mm tt"
  T      The CultureInfo longTime Format Pattern                                      "h:mm:ss tt"
  u      The CultureInfo universalSortableDateTime Format Pattern                     "yyyy-MM-dd HH:mm:ssZ"
  y      The CultureInfo yearMonth Format Pattern                                     "MMMM, yyyy"
  </pre>
  @param {String}   A format string consisting of one or more format spcifiers [Optional].
  @return {String}  A string representation of the current Date object.
  ###
  $P.toString = (format, options) ->
    x = this
    $CI = @cultureInfo
    $CI = Date.AvailableCultureInfo[options.locale]  if options instanceof Object and options.locale
    $CI = $CI or Date.getCultureInfo() # Default to Date.CultureInfo

    # Standard Date and Time Format Strings. Formats pulled from CultureInfo file and
    # may vary by culture.
    if format and format.length is 1
      c = $CI.formatPatterns
      x.t = x.toString
      switch format
        when "d"
          return x.t(c.shortDate, options)
        when "D"
          return x.t(c.longDate, options)
        when "F"
          return x.t(c.fullDateTime, options)
        when "m"
          return x.t(c.monthDay, options)
        when "r"
          return x.t(c.rfc1123, options)
        when "s"
          return x.t(c.sortableDateTime, options)
        when "t"
          return x.t(c.shortTime, options)
        when "T"
          return x.t(c.longTime, options)
        when "u"
          return x.t(c.universalSortableDateTime, options)
        when "y"
          return x.t(c.yearMonth, options)
    ord = (n) ->
      switch n * 1
        when 1, 21
      , 31
          "st"
        when 2, 22
          "nd"
        when 3, 23
          "rd"
        else
          "th"

    (if format then format.replace(/(\\)?((d(?!\w)|ddd?d?)|MM?M?M?|yy(yy)?|hh?|HH?|mm?|ss?|(t(?!\w)|tt)|S)/g, (m) ->
      return m.replace("\\", "")  if m.charAt(0) is "\\"
      x.h = x.getHours
      switch m
        when "hh"
          p (if x.h() < 13 then ((if x.h() is 0 then 12 else x.h())) else (x.h() - 12))
        when "h"
          (if x.h() < 13 then ((if x.h() is 0 then 12 else x.h())) else (x.h() - 12))
        when "HH"
          p x.h()
        when "H"
          x.h()
        when "mm"
          p x.getMinutes()
        when "m"
          x.getMinutes()
        when "ss"
          p x.getSeconds()
        when "s"
          x.getSeconds()
        when "yyyy"
          p x.getFullYear(), 4
        when "yy"
          p x.getFullYear()
        when "dddd"
          $CI.dayNames[x.getDay()]
        when "ddd"
          $CI.abbreviatedDayNames[x.getDay()]
        when "dd"
          p x.getDate()
        when "d"
          x.getDate()
        when "MMMM"
          $CI.monthNames[x.getMonth()]
        when "MMM"
          $CI.abbreviatedMonthNames[x.getMonth()]
        when "MM"
          p (x.getMonth() + 1)
        when "M"
          x.getMonth() + 1
        when "t"
          (if x.h() < 12 then $CI.amDesignator.substring(0, 1) else $CI.pmDesignator.substring(0, 1))
        when "tt"
          (if x.h() < 12 then $CI.amDesignator else $CI.pmDesignator)
        when "S"
          ord x.getDate()
        else
          m
    ) else @_toString())

  $P.getCultureInfo = ->
    @cultureInfo or $D.CultureInfo

  $P.setLocale = (cultureInfo) ->
    if cultureInfo instanceof Object
      @cultureInfo = cultureInfo
    else if Date.AvailableCultureInfo and Date.AvailableCultureInfo[cultureInfo]
      @cultureInfo = Date.AvailableCultureInfo[cultureInfo]
    else
      throw "Unknow locale"

  $D.setLocale = (cultureInfo) ->
    if cultureInfo instanceof Object
      $D.CultureInfo = cultureInfo
    else if Date.AvailableCultureInfo and Date.AvailableCultureInfo[cultureInfo]
      $D.CultureInfo = Date.AvailableCultureInfo[cultureInfo]
    else
      throw "Unknow locale"

  $D.getCultureInfo = ->
    @CultureInfo
)()
