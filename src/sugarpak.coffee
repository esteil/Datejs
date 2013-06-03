###
@version: 1.0 Alpha-1
@author: Coolite Inc. http://www.coolite.com/
@date: 2008-04-13
@copyright: Copyright (c) 2006-2008, Coolite Inc. (http://www.coolite.com/). All rights reserved.
@license: Licensed under The MIT License. See license.txt and http://www.datejs.com/license/.
@website: http://www.datejs.com/
###

###
SugarPak - Domain Specific Language -  Syntactical Sugar **
###
(->
  $D = Date
  $P = $D::
  $N = Number::

  # private
  $P._orient = +1

  # private
  $P._nth = null

  # private
  $P._is = false

  # private
  $P._same = false

  # private
  $P._isSecond = false

  # private
  $N._dateElement = "day"

  ###
  Moves the date to the next instance of a date as specified by the subsequent date element function (eg. .day(), .month()), month name function (eg. .january(), .jan()) or day name function (eg. .friday(), fri()).
  Example
  <pre><code>
  Date.today().next().friday();
  Date.today().next().fri();
  Date.today().next().march();
  Date.today().next().mar();
  Date.today().next().week();
  </code></pre>

  @return {Date}    date
  ###
  $P.next = ->
    @_orient = +1
    this


  ###
  Creates a new Date (Date.today()) and moves the date to the next instance of the date as specified by the subsequent date element function (eg. .day(), .month()), month name function (eg. .january(), .jan()) or day name function (eg. .friday(), fri()).
  Example
  <pre><code>
  Date.next().friday();
  Date.next().fri();
  Date.next().march();
  Date.next().mar();
  Date.next().week();
  </code></pre>

  @return {Date}    date
  ###
  $D.next = ->
    $D.today().next()


  ###
  Moves the date to the previous instance of a date as specified by the subsequent date element function (eg. .day(), .month()), month name function (eg. .january(), .jan()) or day name function (eg. .friday(), fri()).
  Example
  <pre><code>
  Date.today().last().friday();
  Date.today().last().fri();
  Date.today().last().march();
  Date.today().last().mar();
  Date.today().last().week();
  </code></pre>

  @return {Date}    date
  ###
  $P.last = $P.prev = $P.previous = ->
    @_orient = -1
    this


  ###
  Creates a new Date (Date.today()) and moves the date to the previous instance of the date as specified by the subsequent date element function (eg. .day(), .month()), month name function (eg. .january(), .jan()) or day name function (eg. .friday(), fri()).
  Example
  <pre><code>
  Date.last().friday();
  Date.last().fri();
  Date.previous().march();
  Date.prev().mar();
  Date.last().week();
  </code></pre>

  @return {Date}    date
  ###
  $D.last = $D.prev = $D.previous = ->
    $D.today().last()


  ###
  Performs a equality check when followed by either a month name, day name or .weekday() function.
  Example
  <pre><code>
  Date.today().is().friday(); // true|false
  Date.today().is().fri();
  Date.today().is().march();
  Date.today().is().mar();
  </code></pre>

  @return {Boolean}    true|false
  ###
  $P.is = ->
    @_is = true
    this


  ###
  Determines if two date objects occur on/in exactly the same instance of the subsequent date part function.
  The function .same() must be followed by a date part function (example: .day(), .month(), .year(), etc).

  An optional Date can be passed in the date part function. If now date is passed as a parameter, 'Now' is used.

  The following example demonstrates how to determine if two dates fall on the exact same day.

  Example
  <pre><code>
  var d1 = Date.today(); // today at 00:00
  var d2 = new Date();   // exactly now.

  // Do they occur on the same day?
  d1.same().day(d2); // true

  // Do they occur on the same hour?
  d1.same().hour(d2); // false, unless d2 hour is '00' (midnight).

  // What if it's the same day, but one year apart?
  var nextYear = Date.today().add(1).year();

  d1.same().day(nextYear); // false, because the dates must occur on the exact same day.
  </code></pre>

  Scenario: Determine if a given date occurs during some week period 2 months from now.

  Example
  <pre><code>
  var future = Date.today().add(2).months();
  return someDate.same().week(future); // true|false;
  </code></pre>

  @return {Boolean}    true|false
  ###
  $P.same = ->
    @_same = true
    @_isSecond = false
    this


  ###
  Determines if the current date/time occurs during Today. Must be preceded by the .is() function.
  Example
  <pre><code>
  someDate.is().today();    // true|false
  new Date().is().today();  // true
  Date.today().is().today();// true
  Date.today().add(-1).day().is().today(); // false
  </code></pre>

  @return {Boolean}    true|false
  ###
  $P.today = ->
    @same().day()


  ###
  Determines if the current date is a weekday. This function must be preceded by the .is() function.
  Example
  <pre><code>
  Date.today().is().weekday(); // true|false
  </code></pre>

  @return {Boolean}    true|false
  ###
  $P.weekday = ->
    if @_is
      @_is = false
      return (not @is().sat() and not @is().sun())
    false


  ###
  Sets the Time of the current Date instance. A string "6:15 pm" or config object {hour:18, minute:15} are accepted.
  Example
  <pre><code>
  // Set time to 6:15pm with a String
  Date.today().at("6:15pm");

  // Set time to 6:15pm with a config object
  Date.today().at({hour:18, minute:15});
  </code></pre>

  @return {Date}    date
  ###
  $P.at = (time) ->
    (if (typeof time is "string") then $D.parse(@toString("d") + " " + time) else @set(time))


  ###
  Creates a new Date() and adds this (Number) to the date based on the preceding date element function (eg. second|minute|hour|day|month|year).
  Example
  <pre><code>
  // Undeclared Numbers must be wrapped with parentheses. Requirment of JavaScript.
  (3).days().fromNow();
  (6).months().fromNow();

  // Declared Number variables do not require parentheses.
  var n = 6;
  n.months().fromNow();
  </code></pre>

  @return {Date}    A new Date instance
  ###
  $N.fromNow = $N.after = (date) ->
    c = {}
    c[@_dateElement] = this
    ((if (not date) then new Date() else date.clone())).add c


  ###
  Creates a new Date() and subtract this (Number) from the date based on the preceding date element function (eg. second|minute|hour|day|month|year).
  Example
  <pre><code>
  // Undeclared Numbers must be wrapped with parentheses. Requirment of JavaScript.
  (3).days().ago();
  (6).months().ago();

  // Declared Number variables do not require parentheses.
  var n = 6;
  n.months().ago();
  </code></pre>

  @return {Date}    A new Date instance
  ###
  $N.ago = $N.before = (date) ->
    c = {}
    c[@_dateElement] = this * -1
    ((if (not date) then new Date() else date.clone())).add c


  # Do NOT modify the following string tokens. These tokens are used to build dynamic functions.
  # All culture-specific strings can be found in the CultureInfo files. See /trunk/src/globalization/.
  dx = ("sunday monday tuesday wednesday thursday friday saturday").split(/\s/)
  mx = ("january february march april may june july august september october november december").split(/\s/)
  px = ("Millisecond Second Minute Hour Day Week Month Year").split(/\s/)
  pxf = ("Milliseconds Seconds Minutes Hours Date Week Month FullYear").split(/\s/)
  nth = ("final first second third fourth fifth").split(/\s/)
  de = undefined

  ###
  Returns an object literal of all the date parts.
  Example
  <pre><code>
  var o = new Date().toObject();

  // { year: 2008, month: 4, week: 20, day: 13, hour: 18, minute: 9, second: 32, millisecond: 812 }

  // The object properties can be referenced directly from the object.

  alert(o.day);  // alerts "13"
  alert(o.year); // alerts "2008"
  </code></pre>

  @return {Date}    An object literal representing the original date object.
  ###
  $P.toObject = ->
    o = {}
    i = 0

    while i < px.length
      o[px[i].toLowerCase()] = this["get" + pxf[i]]()
      i++
    o


  ###
  Returns a date created from an object literal. Ignores the .week property if set in the config.
  Example
  <pre><code>
  var o = new Date().toObject();

  return Date.fromObject(o); // will return the same date.

  var o2 = {month: 1, day: 20, hour: 18}; // birthday party!
  Date.fromObject(o2);
  </code></pre>

  @return {Date}    An object literal representing the original date object.
  ###
  $D.fromObject = (config) ->
    config.week = null
    Date.today().set config


  # Create day name functions and abbreviated day name functions (eg. monday(), friday(), fri()).
  df = (n) ->
    ->
      if @_is
        @_is = false
        return @getDay() is n
      if @_nth isnt null

        # If the .second() function was called earlier, remove the _orient
        # from the date, and then continue.
        # This is required because 'second' can be used in two different context.
        #
        # Example
        #
        #   Date.today().add(1).second();
        #   Date.march().second().monday();
        #
        # Things get crazy with the following...
        #   Date.march().add(1).second().second().monday(); // but it works!!
        #
        @addSeconds @_orient * -1  if @_isSecond

        # make sure we reset _isSecond
        @_isSecond = false
        ntemp = @_nth
        @_nth = null
        temp = @clone().moveToLastDayOfMonth()
        @moveToNthOccurrence n, ntemp
        throw new RangeError($D.getDayName(n) + " does not occur " + ntemp + " times in the month of " + $D.getMonthName(temp.getMonth()) + " " + temp.getFullYear() + ".")  if this > temp
        return this
      @moveToDayOfWeek n, @_orient

  sdf = (n) ->
    ->
      $C = Date.getCultureInfo()
      t = $D.today()
      shift = n - t.getDay()
      shift = shift + 7  if n is 0 and $C.firstDayOfWeek is 1 and t.getDay() isnt 0
      t.addDays shift

  i = 0

  while i < dx.length

    # Create constant static Day Name variables. Example: Date.MONDAY or Date.MON
    $D[dx[i].toUpperCase()] = $D[dx[i].toUpperCase().substring(0, 3)] = i

    # Create Day Name functions. Example: Date.monday() or Date.mon()
    $D[dx[i]] = $D[dx[i].substring(0, 3)] = sdf(i)

    # Create Day Name instance functions. Example: Date.today().next().monday()
    $P[dx[i]] = $P[dx[i].substring(0, 3)] = df(i)
    i++

  # Create month name functions and abbreviated month name functions (eg. january(), march(), mar()).
  mf = (n) ->
    ->
      if @_is
        @_is = false
        return @getMonth() is n
      @moveToMonth n, @_orient

  smf = (n) ->
    ->
      $D.today().set
        month: n
        day: 1


  j = 0

  while j < mx.length

    # Create constant static Month Name variables. Example: Date.MARCH or Date.MAR
    $D[mx[j].toUpperCase()] = $D[mx[j].toUpperCase().substring(0, 3)] = j

    # Create Month Name functions. Example: Date.march() or Date.mar()
    $D[mx[j]] = $D[mx[j].substring(0, 3)] = smf(j)

    # Create Month Name instance functions. Example: Date.today().next().march()
    $P[mx[j]] = $P[mx[j].substring(0, 3)] = mf(j)
    j++

  # Create date element functions and plural date element functions used with Date (eg. day(), days(), months()).
  ef = (j) ->
    ->

      # if the .second() function was called earlier, the _orient
      # has alread been added. Just return this and reset _isSecond.
      if @_isSecond
        @_isSecond = false
        return this
      if @_same
        @_same = @_is = false
        o1 = @toObject()
        o2 = (arguments_[0] or new Date()).toObject()
        v = ""
        k = j.toLowerCase()
        m = (px.length - 1)

        while m > -1
          v = px[m].toLowerCase()
          return false  unless o1[v] is o2[v]
          break  if k is v
          m--
        return true
      l = j
      l += "s"  unless l.substring(l.length - 1) is "s"
      this["add" + l] @_orient

  nf = (n) ->
    ->
      @_dateElement = n
      this

  k = 0

  while k < px.length
    de = px[k].toLowerCase()

    # Create date element functions and plural date element functions used with Date (eg. day(), days(), months()).
    $P[de] = $P[de + "s"] = ef(px[k])

    # Create date element functions and plural date element functions used with Number (eg. day(), days(), months()).
    $N[de] = $N[de + "s"] = nf(de + "s")
    k++
  $P._ss = ef("Second")
  nthfn = (n) ->
    (dayOfWeek) ->
      return @_ss(arguments_[0])  if @_same
      return @moveToNthOccurrence(dayOfWeek, n)  if dayOfWeek or dayOfWeek is 0
      @_nth = n

      # if the operator is 'second' add the _orient, then deal with it later...
      if n is 2 and (dayOfWeek is `undefined` or dayOfWeek is null)
        @_isSecond = true
        return @addSeconds(@_orient)
      this

  l = 0

  while l < nth.length
    $P[nth[l]] = (if (l is 0) then nthfn(-1) else nthfn(l))
    l++
)()
