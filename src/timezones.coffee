#
#  Added timezone support with big chunks of code from: git://github.com/mde/timezone-js.git
#  TODO: Cleanup
#
(->
  $D = Date
  $P = $D::
  $C = $D.CultureInfo
  getTimezoneInfoByTz = (date, tz) ->
    res = undefined

    # If timezone is specified, get the correct timezone info based on the Date given
    if tz
      res = (if tz is "Etc/UTC" or tz is "Etc/GMT" then
        tzOffset: 0
        tzAbbr: "UTC"
       else timezoneJS.timezone.getTzInfo(date, tz))

    # If no timezone was specified, use the local browser offset
    else
      res =
        tzOffset: date.getTimezoneOffset()
        tzAbbr: null
    res

  $P.showDateFromTzToTz = (fromTz, toTz) ->
    previousOffset = getTimezoneInfoByTz(this, fromTz).tzOffset
    newOffset = getTimezoneInfoByTz(this, toTz).tzOffset

    # this.timezone = tz;
    # this._useCache = false;
    # Set UTC minutes offsets by the delta of the two timezones
    date = new Date(@getTime())
    date.setUTCMinutes date.getUTCMinutes() - newOffset + previousOffset
    date

  $P.getTimezoneInfo = ->
    return @_tzInfo  if @_useCache
    res = undefined

    # If timezone is specified, get the correct timezone info based on the Date given
    if @timezone
      res = (if @timezone is "Etc/UTC" or @timezone is "Etc/GMT" then
        tzOffset: 0
        tzAbbr: "UTC"
       else timezoneJS.timezone.getTzInfo(this, @timezone))

    # If no timezone was specified, use the local browser offset
    else
      res =
        tzOffset: @getTimezoneOffset()
        tzAbbr: null
    @_tzInfo = res
    @_useCache = true
    res


  $P.setTimezoneString = (tz) ->
    @timezone = tz
    this


  #  Change the timezone and keep the relative time the same:
  # eq: 15:00+02:00 (Europe/Berlin) to (Asia/Shanhai) will result in 15:00+08:00
  #     13:00 UTC                                                     07:00 UTC
  $P.changeTimezone = (tz) ->
    previousTz = @timezone
    previousOffset = @getTimezoneInfo().tzOffset
    @timezone = tz
    @_useCache = false

    # Set UTC minutes offsets by the delta of the two timezones
    @setUTCMinutes @getUTCMinutes() + @getTimezoneInfo().tzOffset - previousOffset
    this


  # Convert date to timezone:
  # eq: 15:00+02:00 (Europe/Berlin) to (Asia/Shanhai) will result in 21:00+08:00
  #     13:00 UTC                                                    13:00 UTC
  $P.toTimezone = (tz) ->
    newOffset = new Date().getTimezoneOffset()
    previousOffset = @getTimezoneInfo().tzOffset
    @setUTCMinutes @getUTCMinutes() - @getTimezoneInfo().tzOffset + previousOffset
    this



  ###
  Returns a new Date object that is an exact date and time copy of the original instance.
  @return {Date}    A new Date instance including the timezone
  ###
  $P.clone = ->
    n = new Date(@getTime())
    n.timezone = @timezone
    n
)()

# -----
# The `timezoneJS.Date` object gives you full-blown timezone support, independent from the timezone set on the end-user's machine running the browser. It uses the Olson zoneinfo files for its timezone data.
#
# The constructor function and setter methods use proxy JavaScript Date objects behind the scenes, so you can use strings like '10/22/2006' with the constructor. You also get the same sensible wraparound behavior with numeric parameters (like setting a value of 14 for the month wraps around to the next March).
#
# The other significant difference from the built-in JavaScript Date is that `timezoneJS.Date` also has named properties that store the values of year, month, date, etc., so it can be directly serialized to JSON and used for data transfer.

#
# * Copyright 2010 Matthew Eernisse (mde@fleegix.org)
# * and Open Source Applications Foundation
# *
# * Licensed under the Apache License, Version 2.0 (the "License");
# * you may not use this file except in compliance with the License.
# * You may obtain a copy of the License at
# *
# *   http://www.apache.org/licenses/LICENSE-2.0
# *
# * Unless required by applicable law or agreed to in writing, software
# * distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and
# * limitations under the License.
# *
# * Credits: Ideas included from incomplete JS implementation of Olson
# * parser, "XMLDAte" by Philippe Goetz (philippe.goetz@wanadoo.fr)
# *
# * Contributions:
# * Jan Niehusmann
# * Ricky Romero
# * Preston Hunt (prestonhunt@gmail.com)
# * Dov. B Katz (dov.katz@morganstanley.com)
# * Peter Bergström (pbergstr@mac.com)
# * Long Ho
#

# Standard initialization stuff to make sure the library is
# usable on both client and server (node) side.

# Grab the ajax library from global context.
# This can be jQuery, Zepto or fleegix.
# You can also specify your own transport mechanism by declaring
# `timezoneJS.timezone.transport` to a `function`. More details will follow

# Declare constant list of days and months. Unfortunately this doesn't leave room for i18n due to the Olson data being in English itself

#`{ "Jan": 0, "Feb": 1, "Mar": 2, "Apr": 3, "May": 4, "Jun": 5, "Jul": 6, "Aug": 7, "Sep": 8, "Oct": 9, "Nov": 10, "Dec": 11 }`

#`{ "Sun": 0, "Mon": 1, "Tue": 2, "Wed": 3, "Thu": 4, "Fri": 5, "Sat": 6 }`

#Handle array indexOf in IE

# Format a number to the length = digits. For ex:
#
# `_fixWidth(2, 2) = '02'`
#
# `_fixWidth(1998, 2) = '98'`
#
# This is used to pad numbers in converting date to string in ISO standard.

# Abstraction layer for different transport layers, including fleegix/jQuery/Zepto
#
# Object `opts` include
#
# - `url`: url to ajax query
#
# - `async`: true for asynchronous, false otherwise. If false, return value will be response from URL. This is true by default
#
# - `success`: success callback function
#
# - `error`: error callback function
# Returns response from URL if async is false, otherwise the AJAX request object itself

# // Constructor, which is similar to that of the native Date object itself
# timezoneJS.Date = function () {
#   var args = Array.prototype.slice.apply(arguments)
#   , dt = null
#   , tz = null
#   , arr = [];

#   //We support several different constructors, including all the ones from `Date` object
#   // with a timezone string at the end.
#   //
#   //- `[tz]`: Returns object with time in `tz` specified.
#   //
#   // - `utcMillis`, `[tz]`: Return object with UTC time = `utcMillis`, in `tz`.
#   //
#   // - `Date`, `[tz]`: Returns object with UTC time = `Date.getTime()`, in `tz`.
#   //
#   // - `year, month, [date,] [hours,] [minutes,] [seconds,] [millis,] [tz]: Same as `Date` object
#   // with tz.
#   //
#   // - `Array`: Can be any combo of the above.
#   //
#   //If 1st argument is an array, we can use it as a list of arguments itself
#   if (Object.prototype.toString.call(args[0]) === '[object Array]') {
#     args = args[0];
#   }
#   if (typeof args[args.length - 1] === 'string' && /^[a-zA-Z]+\//gi.test(args[args.length - 1])) {
#     tz = args.pop();
#   }
#   switch (args.length) {
#     case 0:
#       dt = new Date();
#       break;
#     case 1:
#       dt = new Date(args[0]);
#       break;
#     default:
#       for (var i = 0; i < 7; i++) {
#         arr[i] = args[i] || 0;
#       }
#       dt = new Date(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6]);
#       break;
#   }

#   this._useCache = false;
#   this._tzInfo = {};
#   this._day = 0;
#   this.year = 0;
#   this.month = 0;
#   this.date = 0;
#   this.hours = 0;
#   this.minutes = 0;
#   this.seconds = 0;
#   this.milliseconds = 0;
#   this.timezone = tz || null;
#   //Tricky part:
#   // For the cases where there are 1/2 arguments: `timezoneJS.Date(millis, [tz])` and `timezoneJS.Date(Date, [tz])`. The
#   // Date `dt` created should be in UTC. Thus the way I detect such cases is to determine if `arr` is not populated & `tz`
#   // is specified. Because if `tz` is not specified, `dt` can be in local time.
#   if (arr.length) {
#      this.setFromDateObjProxy(dt);
#   } else {
#      this.setFromTimeProxy(dt.getTime(), tz);
#   }
# };

# // Implements most of the native Date object
# timezoneJS.Date.prototype = {
#   getDate: function () { return this.date; },
#   getDay: function () { return this._day; },
#   getFullYear: function () { return this.year; },
#   getMonth: function () { return this.month; },
#   getYear: function () { return this.year; },
#   getHours: function () { return this.hours; },
#   getMilliseconds: function () { return this.milliseconds; },
#   getMinutes: function () { return this.minutes; },
#   getSeconds: function () { return this.seconds; },
#   getUTCDate: function () { return this.getUTCDateProxy().getUTCDate(); },
#   getUTCDay: function () { return this.getUTCDateProxy().getUTCDay(); },
#   getUTCFullYear: function () { return this.getUTCDateProxy().getUTCFullYear(); },
#   getUTCHours: function () { return this.getUTCDateProxy().getUTCHours(); },
#   getUTCMilliseconds: function () { return this.getUTCDateProxy().getUTCMilliseconds(); },
#   getUTCMinutes: function () { return this.getUTCDateProxy().getUTCMinutes(); },
#   getUTCMonth: function () { return this.getUTCDateProxy().getUTCMonth(); },
#   getUTCSeconds: function () { return this.getUTCDateProxy().getUTCSeconds(); },
#   // Time adjusted to user-specified timezone
#   getTime: function () {
#     return this._timeProxy + (this.getTimezoneOffset() * 60 * 1000);
#   },
#   getTimezone: function () { return this.timezone; },
#   getTimezoneOffset: function () { return this.getTimezoneInfo().tzOffset; },
#   getTimezoneAbbreviation: function () { return this.getTimezoneInfo().tzAbbr; },
#   getTimezoneInfo: function () {
#     if (this._useCache) return this._tzInfo;
#     var res;
#     // If timezone is specified, get the correct timezone info based on the Date given
#     if (this.timezone) {
#       res = this.timezone === 'Etc/UTC' || this.timezone === 'Etc/GMT'
#         ? { tzOffset: 0, tzAbbr: 'UTC' }
#         : timezoneJS.timezone.getTzInfo(this._timeProxy, this.timezone);
#     }
#     // If no timezone was specified, use the local browser offset
#     else {
#       res = { tzOffset: this.getLocalOffset(), tzAbbr: null };
#     }
#     this._tzInfo = res;
#     this._useCache = true;
#     return res
#   },
#   getUTCDateProxy: function () {
#     var dt = new Date(this._timeProxy);
#     dt.setUTCMinutes(dt.getUTCMinutes() + this.getTimezoneOffset());
#     return dt;
#   },
#   setDate: function (n) { this.setAttribute('date', n); },
#   setFullYear: function (n) { this.setAttribute('year', n); },
#   setMonth: function (n) { this.setAttribute('month', n); },
#   setYear: function (n) { this.setUTCAttribute('year', n); },
#   setHours: function (n) { this.setAttribute('hours', n); },
#   setMilliseconds: function (n) { this.setAttribute('milliseconds', n); },
#   setMinutes: function (n) { this.setAttribute('minutes', n); },
#   setSeconds: function (n) { this.setAttribute('seconds', n); },
#   setTime: function (n) {
#     if (isNaN(n)) { throw new Error('Units must be a number.'); }
#     this.setFromTimeProxy(n, this.timezone);
#   },
#   setUTCDate: function (n) { this.setUTCAttribute('date', n); },
#   setUTCFullYear: function (n) { this.setUTCAttribute('year', n); },
#   setUTCHours: function (n) { this.setUTCAttribute('hours', n); },
#   setUTCMilliseconds: function (n) { this.setUTCAttribute('milliseconds', n); },
#   setUTCMinutes: function (n) { this.setUTCAttribute('minutes', n); },
#   setUTCMonth: function (n) { this.setUTCAttribute('month', n); },
#   setUTCSeconds: function (n) { this.setUTCAttribute('seconds', n); },
#   setFromDateObjProxy: function (dt) {
#     this.year = dt.getFullYear();
#     this.month = dt.getMonth();
#     this.date = dt.getDate();
#     this.hours = dt.getHours();
#     this.minutes = dt.getMinutes();
#     this.seconds = dt.getSeconds();
#     this.milliseconds = dt.getMilliseconds();
#     this._day =  dt.getDay();
#     this._dateProxy = dt;
#     this._timeProxy = Date.UTC(this.year, this.month, this.date, this.hours, this.minutes, this.seconds, this.milliseconds);
#     this._useCache = false;
#   },
#   setFromTimeProxy: function (utcMillis, tz) {
#     var dt = new Date(utcMillis);
#     var tzOffset;
#     tzOffset = tz ? timezoneJS.timezone.getTzInfo(dt, tz).tzOffset : dt.getTimezoneOffset();
#     dt.setTime(utcMillis + (dt.getTimezoneOffset() - tzOffset) * 60000);
#     this.setFromDateObjProxy(dt);
#   },
#   setAttribute: function (unit, n) {
#     if (isNaN(n)) { throw new Error('Units must be a number.'); }
#     var dt = this._dateProxy;
#     var meth = unit === 'year' ? 'FullYear' : unit.substr(0, 1).toUpperCase() + unit.substr(1);
#     dt['set' + meth](n);
#     this.setFromDateObjProxy(dt);
#   },
#   setUTCAttribute: function (unit, n) {
#     if (isNaN(n)) { throw new Error('Units must be a number.'); }
#     var meth = unit === 'year' ? 'FullYear' : unit.substr(0, 1).toUpperCase() + unit.substr(1);
#     var dt = this.getUTCDateProxy();
#     dt['setUTC' + meth](n);
#     dt.setUTCMinutes(dt.getUTCMinutes() - this.getTimezoneOffset());
#     this.setFromTimeProxy(dt.getTime() + this.getTimezoneOffset() * 60000, this.timezone);
#   },
#   setTimezone: function (tz) {
#     var previousOffset = this.getTimezoneInfo().tzOffset;
#     this.timezone = tz;
#     this._useCache = false;
#     // Set UTC minutes offsets by the delta of the two timezones
#     this.setUTCMinutes(this.getUTCMinutes() - this.getTimezoneInfo().tzOffset + previousOffset);
#   },
#   removeTimezone: function () {
#     this.timezone = null;
#     this._useCache = false;
#   },
#   valueOf: function () { return this.getTime(); },
#   clone: function () {
#     return this.timezone ? new timezoneJS.Date(this.getTime(), this.timezone) : new timezoneJS.Date(this.getTime());
#   },
#   toGMTString: function () { return this.toString('EEE, dd MMM yyyy HH:mm:ss Z', 'Etc/GMT'); },
#   toLocaleString: function () {},
#   toLocaleDateString: function () {},
#   toLocaleTimeString: function () {},
#   toSource: function () {},
#   toISOString: function () { return this.toString('yyyy-MM-ddTHH:mm:ss.SSS', 'Etc/UTC') + 'Z'; },
#   toJSON: function () { return this.toISOString(); },
#   // Allows different format following ISO8601 format:
#   toString: function (format, tz) {
#     // Default format is the same as toISOString
#     if (!format) return this.toString('yyyy-MM-dd HH:mm:ss');
#     var result = format;
#     var tzInfo = tz ? timezoneJS.timezone.getTzInfo(this.getTime(), tz) : this.getTimezoneInfo();
#     var _this = this;
#     // If timezone is specified, get a clone of the current Date object and modify it
#     if (tz) {
#       _this = this.clone();
#       _this.setTimezone(tz);
#     }
#     var hours = _this.getHours();
#     return result
#     // fix the same characters in Month names
#     .replace(/a+/g, function () { return 'k'; })
#     // `y`: year
#     .replace(/y+/g, function (token) { return _fixWidth(_this.getFullYear(), token.length); })
#     // `d`: date
#     .replace(/d+/g, function (token) { return _fixWidth(_this.getDate(), token.length); })
#     // `m`: minute
#     .replace(/m+/g, function (token) { return _fixWidth(_this.getMinutes(), token.length); })
#     // `s`: second
#     .replace(/s+/g, function (token) { return _fixWidth(_this.getSeconds(), token.length); })
#     // `S`: millisecond
#     .replace(/S+/g, function (token) { return _fixWidth(_this.getMilliseconds(), token.length); })
#     // `M`: month. Note: `MM` will be the numeric representation (e.g February is 02) but `MMM` will be text representation (e.g February is Feb)
#     .replace(/M+/g, function (token) {
#       var _month = _this.getMonth(),
#       _len = token.length;
#       if (_len > 3) {
#         return timezoneJS.Months[_month];
#       } else if (_len > 2) {
#         return timezoneJS.Months[_month].substring(0, _len);
#       }
#       return _fixWidth(_month + 1, _len);
#     })
#     // `k`: AM/PM
#     .replace(/k+/g, function () {
#       if (hours >= 12) {
#         if (hours > 12) {
#           hours -= 12;
#         }
#         return 'PM';
#       }
#       return 'AM';
#     })
#     // `H`: hour
#     .replace(/H+/g, function (token) { return _fixWidth(hours, token.length); })
#     // `E`: day
#     .replace(/E+/g, function (token) { return DAYS[_this.getDay()].substring(0, token.length); })
#     // `Z`: timezone abbreviation
#     .replace(/Z+/gi, function () { return tzInfo.tzAbbr; });
#   },
#   toUTCString: function () { return this.toGMTString(); },
#   civilToJulianDayNumber: function (y, m, d) {
#     var a;
#     // Adjust for zero-based JS-style array
#     m++;
#     if (m > 12) {
#       a = parseInt(m/12, 10);
#       m = m % 12;
#       y += a;
#     }
#     if (m <= 2) {
#       y -= 1;
#       m += 12;
#     }
#     a = Math.floor(y / 100);
#     var b = 2 - a + Math.floor(a / 4)
#       , jDt = Math.floor(365.25 * (y + 4716)) + Math.floor(30.6001 * (m + 1)) + d + b - 1524;
#     return jDt;
#   },
#   getLocalOffset: function () {
#     return this._dateProxy.getTimezoneOffset();
#   }
# };

# If there's nothing listed in the main regions for this TZ, check the 'backward' links

# Backward-compat file hasn't loaded yet, try looking in there

# This is for obvious legacy zones (e.g., Iceland) that don't even have a prefix like "America/" that look like normal zones

# Follow links to get to an actual zone

# Backward-compat file hasn't loaded yet, try looking in there

#This is for backward entries like "America/Fort_Wayne" that
# getRegionForTimezone *thinks* it has a region file and zone
# for (e.g., America => 'northamerica'), but in reality it's a
# legacy zone we need the backward file for.

#Do backwards lookup since most use cases deal with newer dates.

#if isUTC is true, date is given in UTC, otherwise it's given
# in local time (ie. date.getUTC*() returns local time components)

#Convert a date to UTC. Depending on the 'type' parameter, the date
# parameter may be:
#
# - `u`, `g`, `z`: already UTC (no adjustment).
#
# - `s`: standard time (adjust for time zone offset but not for DST)
#
# - `w`: wall clock time (adjust for both time zone and DST offset).
#
# DST adjustment is done using the rule given as third argument.
# UTC
# Standard Time
# Wall Clock Time
# to millis

#Step 1:  Find applicable rules for this year.
#
#Step 2:  Sort the rules by effective date.
#
#Step 3:  Check requested date to see if a rule has yet taken effect this year.  If not,
#
#Step 4:  Get the rules for the previous year.  If there isn't an applicable rule for last year, then
# there probably is no current time offset since they seem to explicitly turn off the offset
# when someone stops observing DST.
#
# FIXME if this is not the case and we'll walk all the way back (ugh).
#
#Step 5:  Sort the rules by effective date.
#Step 6:  Apply the most recent rule before the current time.

# Assume that the rule applies to the year of the given date.

# Result for given parameters is already stored

#If we have a specific date, use that!

#Let's hunt for the date.

#Example: `lastThu`

# Start at the last day of the month and work backward.

#Example: `Sun>=15`

#Start at the specified date.

#Go forwards.

#Go backwards.  Looking for the last of a certain day, or operator is "<=" (less likely).

#If previous rule is given, correct for the fact that the starting time of the current
# rule may be specified in local time.

#Exclude future rules.

# Date is in a set range.

# Date is in an "only" year.

#We're in a range from the start year to infinity.

#It's completely okay to have any number of matches here.
# Normally we should only see two, but that doesn't preclude other numbers of matches.
# These matches are applicable to this year.

#While sorting, the time zone in which the rule starting time is specified
# is ignored. This is ok as long as the timespan between two DST changes is
# larger than the DST offset, which is probably always true.
# As the given date may indeed be close to a DST change, it may get sorted
# to a wrong position (off by one), which is corrected below.

#If there are not enough past DST rules...

#The previous rule does not really apply, take the one before that.

#The next rule does already apply, take that one.

#No applicable rule found in this and in previous year.

#FIXME: Right now just falling back to Standard --
# apparently ought to use the last valid rule,
# although in practice that always ought to be Standard

#Chose one of two alternative strings.

#Override default with any passed-in opts

# return this.loadZoneFile(def, opts);

#Wraps callback function in another one that makes
# sure all files have been loaded.

#Get the zone files via XHR -- if the sync flag
# is set to true, it's being called by the lazy-loading
# mechanism, so the result needs to be returned inline.

#Ignore already loaded zones.

# return builtInLoadZoneFile(fileName, opts);

#Ignore Leap.

#Process zone right here and replace 3rd element with the processed array.

#Parse int FROM year and TO year

#Parse time string AT

#Parse offset SAVE

#No zones for these should already exist.

#Create the link.

#Expose transport mechanism and allow overwrite.

#Lazy-load any zones not yet loaded.

#Get the correct region for the zone.

#Get the file and parse it -- use synchronous XHR.

#See if the offset needs adjustment.
(->
  root = this
  timezoneJS = undefined
  if typeof exports isnt "undefined"
    timezoneJS = exports
  else
    timezoneJS = root.timezoneJS = {}
  timezoneJS.VERSION = "1.0.0"
  $ = root.$ or root.jQuery or root.Zepto
  fleegix = root.fleegix
  DAYS = timezoneJS.Days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  MONTHS = timezoneJS.Months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
  SHORT_MONTHS = {}
  SHORT_DAYS = {}
  EXACT_DATE_TIME = {}
  i = 0

  while i < MONTHS.length
    SHORT_MONTHS[MONTHS[i].substr(0, 3)] = i
    i++
  i = 0
  while i < DAYS.length
    SHORT_DAYS[DAYS[i].substr(0, 3)] = i
    i++
  unless Array::indexOf
    Array::indexOf = (el) ->
      i = 0

      while i < @length
        return i  if el is this[i]
        i++
      -1
  _fixWidth = (number, digits) ->
    throw "not a number: " + number  if typeof number isnt "number"
    s = number.toString()
    return number.substr(number.length - digits, number.length)  if number.length > digits
    s = "0" + s  while s.length < digits
    s

  _transport = (opts) ->
    throw new Error("Please use the Fleegix.js XHR module, jQuery ajax, Zepto ajax, or define your own transport mechanism for downloading zone files.")  if (not fleegix or typeof fleegix.xhr is "undefined") and (not $ or typeof $.ajax is "undefined")
    return  unless opts
    throw new Error("URL must be specified")  unless opts.url
    opts.async = true  unless "async" of opts
    unless opts.async
      return (if fleegix and fleegix.xhr then fleegix.xhr.doReq(
        url: opts.url
        async: false
      ) else $.ajax(
        url: opts.url
        async: false
      ).responseText)
    (if fleegix and fleegix.xhr then fleegix.xhr.send(
      url: opts.url
      method: "get"
      handleSuccess: opts.success
      handleErr: opts.error
    ) else $.ajax(
      url: opts.url
      dataType: "text"
      method: "GET"
      error: opts.error
      success: opts.success
    ))

  timezoneJS.timezone = new ->
    invalidTZError = (t) ->
      throw new Error("Timezone \"" + t + "\" is either incorrect, or not loaded in the timezone registry.")
    builtInLoadZoneFile = (fileName, opts) ->
      url = _this.zoneFileBasePath + "/" + fileName
      (if not opts or not opts.async then _this.parseZones(_this.transport(
        url: url
        async: false
      )) else _this.transport(
        async: true
        url: url
        success: (str) ->
          opts.callback()  if _this.parseZones(str) and typeof opts.callback is "function"
          true

        error: ->
          throw new Error("Error retrieving \"" + url + "\" zoneinfo files")
      ))
    getRegionForTimezone = (tz) ->
      exc = regionExceptions[tz]
      reg = undefined
      ret = undefined
      return exc  if exc
      reg = tz.split("/")[0]
      ret = regionMap[reg]
      return ret  if ret
      link = _this.zones[tz]
      return getRegionForTimezone(link)  if typeof link is "string"
      unless _this.loadedZones.backward
        _this.loadZoneFile "backward"
        return getRegionForTimezone(tz)
      invalidTZError tz
    parseTimeString = (str) ->
      pat = /(\d+)(?::0*(\d*))?(?::0*(\d*))?([wsugz])?$/
      hms = str.match(pat)
      hms[1] = parseInt(hms[1], 10)
      hms[2] = (if hms[2] then parseInt(hms[2], 10) else 0)
      hms[3] = (if hms[3] then parseInt(hms[3], 10) else 0)
      hms
    processZone = (z) ->
      return  unless z[3]
      yea = parseInt(z[3], 10)
      mon = 11
      dat = 31
      if z[4]
        mon = SHORT_MONTHS[z[4].substr(0, 3)]
        dat = parseInt(z[5], 10) or 1
      string = (if z[6] then z[6] else "00:00:00")
      t = parseTimeString(string)
      [yea, mon, dat, t[1], t[2], t[3]]
    getZone = (dt, tz) ->
      utcMillis = (if typeof dt is "number" then dt else new Date(dt).getTime())
      t = tz
      zoneList = _this.zones[t]
      while typeof zoneList is "string"
        t = zoneList
        zoneList = _this.zones[t]
      unless zoneList
        unless _this.loadedZones.backward
          _this.loadZoneFile "backward"
          return getZone(dt, tz)
        invalidTZError t
      throw new Error("No Zone found for \"" + tz + "\" on " + dt)  if zoneList.length is 0
      i = zoneList.length - 1

      while i >= 0
        z = zoneList[i]
        break  if z[3] and utcMillis > z[3]
        i--
      zoneList[i + 1]
    getBasicOffset = (time) ->
      off_ = parseTimeString(time)
      adj = (if time.indexOf("-") is 0 then -1 else 1)
      off_ = adj * (((off_[1] * 60 + off_[2]) * 60 + off_[3]) * 1000)
      off_ / 60 / 1000
    getRule = (dt, zone, isUTC) ->
      date = (if typeof dt is "number" then new Date(dt) else dt)
      ruleset = zone[1]
      basicOffset = zone[0]
      convertDateToUTC = (date, type, rule) ->
        offset = 0
        if type is "u" or type is "g" or type is "z"
          offset = 0
        else if type is "s"
          offset = basicOffset
        else if type is "w" or not type
          offset = getAdjustedOffset(basicOffset, rule)
        else
          throw ("unknown type " + type)
        offset *= 60 * 1000
        new Date(date.getTime() + offset)

      convertRuleToExactDateAndTime = (yearAndRule, prevRule) ->
        year = yearAndRule[0]
        rule = yearAndRule[1]
        hms = rule[5]
        effectiveDate = undefined
        EXACT_DATE_TIME[year] = {}  unless EXACT_DATE_TIME[year]
        unless EXACT_DATE_TIME[year][rule]
          unless isNaN(rule[4])
            effectiveDate = new Date(Date.UTC(year, SHORT_MONTHS[rule[3]], rule[4], hms[1], hms[2], hms[3], 0))
          else
            targetDay = undefined
            operator = undefined
            if rule[4].substr(0, 4) is "last"
              effectiveDate = new Date(Date.UTC(year, SHORT_MONTHS[rule[3]] + 1, 1, hms[1] - 24, hms[2], hms[3], 0))
              targetDay = SHORT_DAYS[rule[4].substr(4, 3)]
              operator = "<="
            else
              effectiveDate = new Date(Date.UTC(year, SHORT_MONTHS[rule[3]], rule[4].substr(5), hms[1], hms[2], hms[3], 0))
              targetDay = SHORT_DAYS[rule[4].substr(0, 3)]
              operator = rule[4].substr(3, 2)
            ourDay = effectiveDate.getUTCDay()
            if operator is ">="
              effectiveDate.setUTCDate effectiveDate.getUTCDate() + (targetDay - ourDay + ((if (targetDay < ourDay) then 7 else 0)))
            else
              effectiveDate.setUTCDate effectiveDate.getUTCDate() + (targetDay - ourDay - ((if (targetDay > ourDay) then 7 else 0)))
          EXACT_DATE_TIME[year][rule] = effectiveDate
        effectiveDate = convertDateToUTC(effectiveDate, hms[4], prevRule)  if prevRule
        effectiveDate

      findApplicableRules = (year, ruleset) ->
        applicableRules = []
        i = 0

        while ruleset and i < ruleset.length
          applicableRules.push [year, ruleset[i]]  if ruleset[i][0] <= year and (ruleset[i][1] >= year or (ruleset[i][0] is year and ruleset[i][1] is "only") or ruleset[i][1] is "max")
          i++
        applicableRules

      compareDates = (a, b, prev) ->
        year = undefined
        rule = undefined
        if a.constructor isnt Date
          year = a[0]
          rule = a[1]
          a = (if (not prev and EXACT_DATE_TIME[year] and EXACT_DATE_TIME[year][rule]) then EXACT_DATE_TIME[year][rule] else convertRuleToExactDateAndTime(a, prev))
        else a = convertDateToUTC(a, (if isUTC then "u" else "w"), prev)  if prev
        if b.constructor isnt Date
          year = b[0]
          rule = b[1]
          b = (if (not prev and EXACT_DATE_TIME[year] and EXACT_DATE_TIME[year][rule]) then EXACT_DATE_TIME[year][rule] else convertRuleToExactDateAndTime(b, prev))
        else b = convertDateToUTC(b, (if isUTC then "u" else "w"), prev)  if prev
        a = Number(a)
        b = Number(b)
        a - b

      year = date.getUTCFullYear()
      applicableRules = undefined
      applicableRules = findApplicableRules(year, _this.rules[ruleset])
      applicableRules.push date
      applicableRules.sort compareDates
      if applicableRules.indexOf(date) < 2
        applicableRules = applicableRules.concat(findApplicableRules(year - 1, _this.rules[ruleset]))
        applicableRules.sort compareDates
      pinpoint = applicableRules.indexOf(date)
      if pinpoint > 1 and compareDates(date, applicableRules[pinpoint - 1], applicableRules[pinpoint - 2][1]) < 0
        return applicableRules[pinpoint - 2][1]
      else if pinpoint > 0 and pinpoint < applicableRules.length - 1 and compareDates(date, applicableRules[pinpoint + 1], applicableRules[pinpoint - 1][1]) > 0
        return applicableRules[pinpoint + 1][1]
      else return null  if pinpoint is 0
      applicableRules[pinpoint - 1][1]
    getAdjustedOffset = (off_, rule) ->
      -Math.ceil(rule[6] - off_)
    getAbbreviation = (zone, rule) ->
      res = undefined
      base = zone[2]
      if base.indexOf("%s") > -1
        repl = undefined
        if rule
          repl = (if rule[7] is "-" then "" else rule[7])
        else
          repl = "S"
        res = base.replace("%s", repl)
      else if base.indexOf("/") > -1
        res = base.split("/", 2)[(if rule[6] then 1 else 0)]
      else
        res = base
      res
    _this = this
    regionMap =
      Etc: "etcetera"
      EST: "northamerica"
      MST: "northamerica"
      HST: "northamerica"
      EST5EDT: "northamerica"
      CST6CDT: "northamerica"
      MST7MDT: "northamerica"
      PST8PDT: "northamerica"
      America: "northamerica"
      Pacific: "australasia"
      Atlantic: "europe"
      Africa: "africa"
      Indian: "africa"
      Antarctica: "antarctica"
      Asia: "asia"
      Australia: "australasia"
      Europe: "europe"
      WET: "europe"
      CET: "europe"
      MET: "europe"
      EET: "europe"

    regionExceptions =
      "Pacific/Honolulu": "northamerica"
      "Atlantic/Bermuda": "northamerica"
      "Atlantic/Cape_Verde": "africa"
      "Atlantic/St_Helena": "africa"
      "Indian/Kerguelen": "antarctica"
      "Indian/Chagos": "asia"
      "Indian/Maldives": "asia"
      "Indian/Christmas": "australasia"
      "Indian/Cocos": "australasia"
      "America/Danmarkshavn": "europe"
      "America/Scoresbysund": "europe"
      "America/Godthab": "europe"
      "America/Thule": "europe"
      "Asia/Yekaterinburg": "europe"
      "Asia/Omsk": "europe"
      "Asia/Novosibirsk": "europe"
      "Asia/Krasnoyarsk": "europe"
      "Asia/Irkutsk": "europe"
      "Asia/Yakutsk": "europe"
      "Asia/Vladivostok": "europe"
      "Asia/Sakhalin": "europe"
      "Asia/Magadan": "europe"
      "Asia/Kamchatka": "europe"
      "Asia/Anadyr": "europe"
      "Africa/Ceuta": "europe"
      "America/Argentina/Buenos_Aires": "southamerica"
      "America/Argentina/Cordoba": "southamerica"
      "America/Argentina/Tucuman": "southamerica"
      "America/Argentina/La_Rioja": "southamerica"
      "America/Argentina/San_Juan": "southamerica"
      "America/Argentina/Jujuy": "southamerica"
      "America/Argentina/Catamarca": "southamerica"
      "America/Argentina/Mendoza": "southamerica"
      "America/Argentina/Rio_Gallegos": "southamerica"
      "America/Argentina/Ushuaia": "southamerica"
      "America/Aruba": "southamerica"
      "America/La_Paz": "southamerica"
      "America/Noronha": "southamerica"
      "America/Belem": "southamerica"
      "America/Fortaleza": "southamerica"
      "America/Recife": "southamerica"
      "America/Araguaina": "southamerica"
      "America/Maceio": "southamerica"
      "America/Bahia": "southamerica"
      "America/Sao_Paulo": "southamerica"
      "America/Campo_Grande": "southamerica"
      "America/Cuiaba": "southamerica"
      "America/Porto_Velho": "southamerica"
      "America/Boa_Vista": "southamerica"
      "America/Manaus": "southamerica"
      "America/Eirunepe": "southamerica"
      "America/Rio_Branco": "southamerica"
      "America/Santiago": "southamerica"
      "Pacific/Easter": "southamerica"
      "America/Bogota": "southamerica"
      "America/Curacao": "southamerica"
      "America/Guayaquil": "southamerica"
      "Pacific/Galapagos": "southamerica"
      "Atlantic/Stanley": "southamerica"
      "America/Cayenne": "southamerica"
      "America/Guyana": "southamerica"
      "America/Asuncion": "southamerica"
      "America/Lima": "southamerica"
      "Atlantic/South_Georgia": "southamerica"
      "America/Paramaribo": "southamerica"
      "America/Port_of_Spain": "southamerica"
      "America/Montevideo": "southamerica"
      "America/Caracas": "southamerica"

    @zoneFileBasePath
    @zoneFiles = ["africa", "antarctica", "asia", "australasia", "backward", "etcetera", "europe", "northamerica", "pacificnew", "southamerica"]
    @loadingSchemes =
      PRELOAD_ALL: "preloadAll"
      LAZY_LOAD: "lazyLoad"
      MANUAL_LOAD: "manualLoad"

    @loadingScheme = @loadingSchemes.LAZY_LOAD
    @loadedZones = {}
    @zones = {}
    @rules = {}
    @init = (o) ->
      opts = async: true
      def = @defaultZoneFile = (if @loadingScheme is @loadingSchemes.PRELOAD_ALL then @zoneFiles else "northamerica")
      done = 0
      callbackFn = undefined
      for p of o
        opts[p] = o[p]
      return  if typeof def is "string"
      callbackFn = opts.callback
      opts.callback = ->
        done++
        (done is def.length) and typeof callbackFn is "function" and callbackFn()

      i = 0

      while i < def.length
        @loadZoneFile def[i], opts
        i++

    @loadZoneFile = (fileName, opts) ->
      throw new Error("Please define a base path to your zone file directory -- timezoneJS.timezone.zoneFileBasePath.")  if typeof @zoneFileBasePath is "undefined"
      return  if @loadedZones[fileName]
      @loadedZones[fileName] = true
      @loadZoneJSONData @zoneFileBasePath + fileName + ".json", true

    @loadZoneJSONData = (url, sync) ->
      processData = (data) ->
        data = eval_("(" + data + ")")
        for z of data.zones
          _this.zones[z] = data.zones[z]
        for r of data.rules
          _this.rules[r] = data.rules[r]

      (if sync then processData(_this.transport(
        url: url
        async: false
      )) else _this.transport(
        url: url
        success: processData
      ))

    @loadZoneDataFromObject = (data) ->
      return  unless data
      for z of data.zones
        _this.zones[z] = data.zones[z]
      for r of data.rules
        _this.rules[r] = data.rules[r]

    @getAllZones = ->
      arr = []
      for z of @zones
        arr.push z
      arr.sort()

    @parseZones = (str) ->
      lines = str.split("\n")
      arr = []
      chunk = ""
      l = undefined
      zone = null
      rule = null
      i = 0

      while i < lines.length
        l = lines[i]
        l = "Zone " + zone + l  if l.match(/^\s/)
        l = l.split("#")[0]
        if l.length > 3
          arr = l.split(/\s+/)
          chunk = arr.shift()
          switch chunk
            when "Zone"
              zone = arr.shift()
              _this.zones[zone] = []  unless _this.zones[zone]
              break  if arr.length < 3
              arr.splice 3, arr.length, processZone(arr)
              arr[3] = Date.UTC.apply(null, arr[3])  if arr[3]
              arr[0] = -getBasicOffset(arr[0])
              _this.zones[zone].push arr
            when "Rule"
              rule = arr.shift()
              _this.rules[rule] = []  unless _this.rules[rule]
              arr[0] = parseInt(arr[0], 10)
              arr[1] = parseInt(arr[1], 10) or arr[1]
              arr[5] = parseTimeString(arr[5])
              arr[6] = getBasicOffset(arr[6])
              _this.rules[rule].push arr
            when "Link"
              throw new Error("Error with Link " + arr[1] + ". Cannot create link of a preexisted zone.")  if _this.zones[arr[1]]
              _this.zones[arr[1]] = arr[0]
        i++
      true

    @transport = _transport
    @getTzInfo = (dt, tz, isUTC) ->
      if @loadingScheme is @loadingSchemes.LAZY_LOAD
        zoneFile = getRegionForTimezone(tz)
        throw new Error("Not a valid timezone ID.")  unless zoneFile
        @loadZoneFile tz  unless @loadedZones[zoneFile]
      z = getZone(dt, tz)
      off_ = z[0]
      rule = getRule(dt, z, isUTC)
      off_ = getAdjustedOffset(off_, rule)  if rule
      abbr = getAbbreviation(z, rule)
      tzOffset: off_
      tzAbbr: abbr
).call this
