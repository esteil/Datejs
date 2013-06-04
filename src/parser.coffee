###
@version: 1.0 Alpha-1
@author: Coolite Inc. http://www.coolite.com/
@date: 2008-04-13
@copyright: Copyright (c) 2006-2008, Coolite Inc. (http://www.coolite.com/). All rights reserved.
@license: Licensed under The MIT License. See license.txt and http://www.datejs.com/license/.
@website: http://www.datejs.com/
###
(->
  Date.Parsing = Exception: (s) ->
    @message = "Parse error at '" + s.substring(0, 10) + " ...'"

  $P = Date.Parsing
  _ = $P.Operators =

    #
    # Tokenizers
    #
    rtoken: (r) -> # regex token
      (s) ->
        mx = s.match(r)
        if mx
          [mx[0], s.substring(mx[0].length)]
        else
          throw new $P.Exception(s)

    token: (s) -> # whitespace-eating token
      (s) ->
        _.rtoken(new RegExp("^s*" + s + "s*")) s


    # Removed .strip()
    # return _.rtoken(new RegExp("^\s*" + s + "\s*"))(s).strip();
    stoken: (s) -> # string token
      _.rtoken new RegExp("^" + s)


    #
    # Atomic Operators
    #
    until: (p) ->
      (s) ->
        qx = []
        rx = null
        while s.length
          try
            rx = p.call(this, s)
          catch e
            qx.push rx[0]
            s = rx[1]
            continue
          break
        [qx, s]

    many: (p) ->
      (s) ->
        rx = []
        r = null
        while s.length
          try
            r = p.call(this, s)
          catch e
            return [rx, s]
          rx.push r[0]
          s = r[1]
        [rx, s]


    # generator operators -- see below
    optional: (p) ->
      (s) ->
        r = null
        try
          r = p.call(this, s)
        catch e
          return [null, s]
        [r[0], r[1]]

    not: (p) ->
      (s) ->
        try
          p.call this, s
        catch e
          return [null, s]
        throw new $P.Exception(s)

    ignore: (p) ->
      (if p then (s) ->
        r = null
        r = p.call(this, s)
        [null, r[1]]
       else null)

    product: ->
      px = arguments[0]
      qx = Array::slice.call(arguments, 1)
      rx = []
      i = 0

      while i < px.length
        rx.push _.each(px[i], qx)
        i++
      rx

    cache: (rule) ->
      cache = {}
      r = null
      (s) ->
        try
          `r = cache[s] = (cache[s] || rule.call(this, s));`
        catch e
          r = cache[s] = e
        if r instanceof $P.Exception
          throw r
        else
          r


    # vector operators -- see below
    any: ->
      px = arguments
      (s) ->
        r = null
        i = 0

        while i < px.length
          continue  unless px[i]?
          try
            r = (px[i].call(this, s))
          catch e
            r = null
          return r  if r
          i++
        throw new $P.Exception(s)

    each: ->
      px = arguments
      (s) ->
        rx = []
        r = null
        i = 0

        while i < px.length
          continue  unless px[i]?
          try
            r = (px[i].call(this, s))
          catch e
            throw new $P.Exception(s)
          rx.push r[0]
          s = r[1]
          i++
        [rx, s]

    all: ->
      px = arguments
      _ = _
      _.each _.optional(px)


    # delimited operators
    sequence: (px, d, c) ->
      d = d or _.rtoken(/^\s*/)
      c = c or null
      return px[0]  if px.length is 1
      (s) ->
        r = null
        q = null
        rx = []
        i = 0

        while i < px.length
          try
            r = px[i].call(this, s)
          catch e
            break
          rx.push r[0]
          try
            q = d.call(this, r[1])
          catch ex
            q = null
            break
          s = q[1]
          i++
        throw new $P.Exception(s)  unless r
        throw new $P.Exception(q[1])  if q
        if c
          try
            r = c.call(this, r[1])
          catch ey
            throw new $P.Exception(r[1])
        [rx, ((if r then r[1] else s))]


    #
    # Composite Operators
    #
    between: (d1, p, d2) ->
      d2 = d2 or d1
      _fn = _.each(_.ignore(d1), p, _.ignore(d2))
      (s) ->
        rx = _fn.call(this, s)
        [[rx[0][0], r[0][2]], rx[1]]

    list: (p, d, c) ->
      d = d or _.rtoken(/^\s*/)
      c = c or null
      (if p instanceof Array then _.each(_.product(p.slice(0, -1), _.ignore(d)), p.slice(-1), _.ignore(c)) else _.each(_.many(_.each(p, _.ignore(d))), px, _.ignore(c)))

    set: (px, d, c) ->
      d = d or _.rtoken(/^\s*/)
      c = c or null
      (s) ->

        # r is the current match, best the current 'best' match
        # which means it parsed the most amount of input
        r = null
        p = null
        q = null
        rx = null
        best = [[], s]
        last = false

        # go through the rules in the given set
        i = 0

        while i < px.length

          # last is a flag indicating whether this must be the last element
          # if there is only 1 element, then it MUST be the last one
          q = null
          p = null
          r = null
          last = (px.length is 1)

          # first, we try simply to match the current pattern
          # if not, try the next pattern
          try
            r = px[i].call(this, s)
          catch e
            continue

          # since we are matching against a set of elements, the first
          # thing to do is to add r[0] to matched elements
          rx = [[r[0]], r[1]]

          # if we matched and there is still input to parse and
          # we don't already know this is the last element,
          # we're going to next check for the delimiter ...
          # if there's none, or if there's no input left to parse
          # than this must be the last element after all ...
          if r[1].length > 0 and not last
            try
              q = d.call(this, r[1])
            catch ex
              last = true
          else
            last = true

          # if we parsed the delimiter and now there's no more input,
          # that means we shouldn't have parsed the delimiter at all
          # so don't update r and mark this as the last element ...
          last = true  if not last and q[1].length is 0

          # so, if this isn't the last element, we're going to see if
          # we can get any more matches from the remaining (unmatched)
          # elements ...
          unless last

            # build a list of the remaining rules we can match against,
            # i.e., all but the one we just matched against
            qx = []
            j = 0

            while j < px.length
              qx.push px[j]  unless i is j
              j++

            # now invoke recursively set with the remaining input
            # note that we don't include the closing delimiter ...
            # we'll check for that ourselves at the end
            p = _.set(qx, d).call(this, q[1])

            # if we got a non-empty set as a result ...
            # (otw rx already contains everything we want to match)
            if p[0].length > 0

              # update current result, which is stored in rx ...
              # basically, pick up the remaining text from p[1]
              # and concat the result from p[0] so that we don't
              # get endless nesting ...
              rx[0] = rx[0].concat(p[0])
              rx[1] = p[1]

          # at this point, rx either contains the last matched element
          # or the entire matched set that starts with this element.

          # now we just check to see if this variation is better than
          # our best so far, in terms of how much of the input is parsed
          best = rx  if rx[1].length < best[1].length

          # if we've parsed all the input, then we're finished
          break  if best[1].length is 0
          i++

        # so now we've either gone through all the patterns trying them
        # as the initial match; or we found one that parsed the entire
        # input string ...

        # if best has no matches, just return empty set ...
        return best  if best[0].length is 0

        # if a closing delimiter is provided, then we have to check it also
        if c

          # we try this even if there is no remaining input because the pattern
          # may well be optional or match empty input ...
          try
            q = c.call(this, best[1])
          catch ey
            throw new $P.Exception(best[1])

          # it parsed ... be sure to update the best match remaining input
          best[1] = q[1]

        # if we're here, either there was no closing delimiter or we parsed it
        # so now we have the best match; just return it!
        best

    forward: (gr, fname) ->
      (s) ->
        gr[fname].call this, s


    #
    # Translation Operators
    #
    replace: (rule, repl) ->
      (s) ->
        r = rule.call(this, s)
        [repl, r[1]]

    process: (rule, fn) ->
      (s) ->
        r = rule.call(this, s)
        [fn.call(this, r[0]), r[1]]

    min: (min, rule) ->
      (s) ->
        rx = rule.call(this, s)
        throw new $P.Exception(s)  if rx[0].length < min
        rx


  # Generator Operators And Vector Operators

  # Generators are operators that have a signature of F(R) => R,
  # taking a given rule and returning another rule, such as
  # ignore, which parses a given rule and throws away the result.

  # Vector operators are those that have a signature of F(R1,R2,...) => R,
  # take a list of rules and returning a new rule, such as each.

  # Generator operators are converted (via the following _generator
  # function) into functions that can also take a list or array of rules
  # and return an array of new rules as though the function had been
  # called on each rule in turn (which is what actually happens).

  # This allows generators to be used with vector operators more easily.
  # Example:
  # each(ignore(foo, bar)) instead of each(ignore(foo), ignore(bar))

  # This also turns generators into vector operators, which allows
  # constructs like:
  # not(cache(foo, bar))
  _generator = (op) ->
    ->
      args = null
      rx = []
      if arguments.length > 1
        args = Array::slice.call(arguments)
      else args = arguments[0]  if arguments[0] instanceof Array
      if args
        i = 0
        px = args.shift()

        while i < px.length
          args.unshift px[i]
          rx.push op.apply(null, args)
          args.shift()
          return rx
          i++
      else
        op.apply null, arguments

  gx = "optional not ignore cache".split(/\s/)
  i = 0

  while i < gx.length
    _[gx[i]] = _generator(_[gx[i]])
    i++
  _vector = (op) ->
    ->
      if arguments[0] instanceof Array
        op.apply null, arguments[0]
      else
        op.apply null, arguments

  vx = "each any all".split(/\s/)
  j = 0

  while j < vx.length
    _[vx[j]] = _vector(_[vx[j]])
    j++
)()
(->
  $D = Date
  $P = $D::
  flattenAndCompact = (ax) ->
    rx = []
    i = 0

    while i < ax.length
      if ax[i] instanceof Array
        rx = rx.concat(flattenAndCompact(ax[i]))
      else
        rx.push ax[i]  if ax[i]
      i++
    rx

  $D.Grammar = {}
  $D.Translator =
    hour: (s) ->
      ->
        @hour = Number(s)

    minute: (s) ->
      ->
        @minute = Number(s)

    second: (s) ->
      ->
        @second = Number(s)

    millisecond: (s) ->
      ->
        @millisecond = Number(s)

    meridian: (s) ->
      ->
        @meridian = s.slice(0, 1).toLowerCase()

    timezone: (s) ->
      ->
        n = s.replace(/[^\d\+\-]/g, "")
        if n.length

          # parse offset into iso8601 parts
          zp = n.match(/(\+|-)(\d{2})(\d{2})?/)

          # minute offsets must be converted to base of 100
          mo = parseInt((parseInt(zp[3]) or 0) / .6).toString()
          mo = (if mo.length < 2 then "0" + mo else mo)
          @timezoneOffset = zp[1] + zp[2] + mo
        else
          @timezone = s.toLowerCase()

    day: (x) ->
      s = x[0]
      ->
        @day = Number(s.match(/\d+/)[0])

    month: (s) ->
      ->
        @month = (if (s.length is 3) then "jan feb mar apr may jun jul aug sep oct nov dec".indexOf(s) / 4 else Number(s) - 1)

    year: (s) ->
      $C = Date.getCultureInfo()
      ->
        n = Number(s)
        @year = ((if (s.length > 2) then n else (n + ((if ((n + 2000) < $C.twoDigitYearMax) then 2000 else 1900)))))

    rday: (s) ->
      ->
        switch s
          when "yesterday"
            @days = -1
          when "tomorrow"
            @days = 1
          when "today"
            @days = 0
          when "now"
            @days = 0
            @now = true

    finishExact: (x) ->
      x = (if (x instanceof Array) then x else [x])
      i = 0

      while i < x.length
        x[i].call this  if x[i]
        i++
      now = new Date()
      @day = now.getDate()  if (@hour or @minute) and (not @month and not @year and not @day)
      @year = now.getFullYear()  unless @year
      @month = now.getMonth()  if not @month and @month isnt 0
      @day = 1  unless @day
      @hour = 0  unless @hour
      @minute = 0  unless @minute
      @second = 0  unless @second
      @millisecond = 0  unless @millisecond
      if @meridian and @hour
        if @meridian is "p" and @hour < 12
          @hour = @hour + 12
        else @hour = 0  if @meridian is "a" and @hour is 12
      throw new RangeError(@day + " is not a valid value for days.")  if @day > $D.getDaysInMonth(@year, @month)
      r = new Date(@year, @month, @day, @hour, @minute, @second, @millisecond)
      if @timezone
        r.set timezone: @timezone
      else r.setTimezoneOffset @timezoneOffset  if @timezoneOffset
      r

    finish: (x) ->
      x = (if (x instanceof Array) then flattenAndCompact(x) else [x])
      return null  if x.length is 0
      i = 0

      while i < x.length
        x[i].call this  if typeof x[i] is "function"
        i++
      today = $D.today()

      # For parsing: "now"
      if @now and not @unit and not @operator
        return new Date()
      else today = new Date()  if @now
      expression = !!(@days and @days isnt null or @orient or @operator or @bias)
      realExpression = !!(@days and @days isnt null or @orient or @operator)
      gap = undefined
      mod = undefined
      orient = undefined
      orient = ((if (@orient is "past" or @operator is "subtract" or @bias is "past") then -1 else 1))

      # For parsing: "last second", "next minute", "previous hour", "+5 seconds",
      #   "-5 hours", "5 hours", "7 hours ago"
      today.setTimeToNow()  if not @now and "hour minute second".indexOf(@unit) isnt -1

      # For parsing: "5 hours", "2 days", "3 years ago",
      #    "7 days from now"
      if (@month or @month is 0) and ("year day hour minute second".indexOf(@unit) isnt -1)
        @value = @month + 1
        @month = null
        expression = true

      # For parsing: "monday @ 8pm", "12p on monday", "Friday"
      if not expression and @weekday and not @day and not @days
        temp = Date[@weekday]()
        @day = temp.getDate()
        @month = temp.getMonth()  unless @month
        @year = temp.getFullYear()

      # For parsing: "prev thursday", "next friday", "last friday at 20:00"
      if expression and @weekday and @unit isnt "month"
        @unit = "day"
        gap = ($D.getDayNumberFromName(@weekday) - today.getDay())
        mod = 7
        @days = (if gap then ((gap + (orient * mod)) % mod) else (orient * mod))

      # For parsing: "t+1 m", "today + 1 month", "+1 month", "-5 months"
      if not @month and @value and @unit is "month" and not @now
        @month = @value
        expression = true

      # For parsing: "last january", "prev march", "next july", "today + 1 month",
      #   "+5 months"
      if (expression and not @bias) and (@month or @month is 0) and @unit isnt "year"
        @unit = "month"
        gap = (@month - today.getMonth())
        mod = 12
        @months = (if gap then ((gap + (orient * mod)) % mod) else (orient * mod))
        @month = null

      # For parsing: "last monday", "last friday", "previous day",
      #   "next week", "next month", "next year",
      #   "today+", "+", "-", "yesterday at 4:00", "last friday at 20:00"
      @value = 1  if not @value and realExpression

      # For parsing: "15th at 20:15", "15th at 8pm", "today+", "t+5"
      @unit = "day"  if not @unit and (not expression or @value)

      # For parsing: "15th at 20:15", "15th at 8pm"
      if (not expression or @bias) and @value and (not @unit or @unit is "day") and not @day
        @unit = "day"
        @day = @value * 1

      # For parsing: "last minute", "+5 hours", "previous month", "1 year ago tomorrow"
      this[@unit + "s"] = @value * orient  if @unit and (not this[@unit + "s"] or @operator)

      # For parsing: "July 8th, 2004, 10:30 PM", "07/15/04 6 AM",
      #   "monday @ 8am", "10:30:45 P.M."
      if @meridian and @hour
        if @meridian is "p" and @hour < 12
          @hour = @hour + 12
        else @hour = 0  if @meridian is "a" and @hour is 12

      # For parsing: "3 months ago saturday at 5:00 pm" (does not actually parse)
      if @weekday and not @day and not @days
        temp = Date[@weekday]()
        @day = temp.getDate()
        @month = temp.getMonth()  if temp.getMonth() isnt today.getMonth()

      # For parsing: "July 2004", "1997-07", "2008/10", "november"
      @day = 1  if (@month or @month is 0) and not @day

      # For parsing: "3 weeks" (does not actually parse)
      return Date.today().setWeek(@value)  if not @orient and not @operator and @unit is "week" and @value and not @day and not @month
      today.set this
      if @bias
        @days = null  if @day
        unless @day
          @days = 1 * orient  if (@bias is "past" and today > new Date()) or (@bias is "future" and today < new Date())
        else if not @month and not @months
          @months = 1 * orient  if (@bias is "past" and today > new Date()) or (@bias is "future" and today < new Date())
        else @years = 1 * orient  if (@bias is "past" and today > new Date()) or (@bias is "future" and today < new Date())  unless @year
        expression = true
      today.add this  if expression
      today

  _ = $D.Parsing.Operators
  g = $D.Grammar
  t = $D.Translator
  _fn = undefined
  g.datePartDelimiter = _.rtoken(/^([\s\-\.\,\/\x27]+)/)
  g.timePartDelimiter = _.stoken(":")
  g.whiteSpace = _.rtoken(/^\s*/)
  g.generalDelimiter = _.rtoken(/^(([\s\,]|at|@|on)+)/)
  _C = {}
  g.ctoken = (keys) ->
    fn = _C[keys]
    $C = Date.getCultureInfo()
    unless fn
      c = $C.regexPatterns
      kx = keys.split(/\s+/)
      px = []
      i = 0

      while i < kx.length
        px.push _.replace(_.rtoken(c[kx[i]]), kx[i])
        i++
      fn = _C[keys] = _.any.apply(null, px)
    fn

  g.ctoken2 = (key) ->
    $C = Date.getCultureInfo()
    _.rtoken $C.regexPatterns[key]


  # hour, minute, second, meridian, timezone
  g.h = _.cache(_.process(_.rtoken(/^(0[0-9]|1[0-2]|[1-9])/), t.hour))
  g.hh = _.cache(_.process(_.rtoken(/^(0[0-9]|1[0-2])/), t.hour))
  g.H = _.cache(_.process(_.rtoken(/^([0-1][0-9]|2[0-3]|[0-9])/), t.hour))
  g.HH = _.cache(_.process(_.rtoken(/^([0-1][0-9]|2[0-3])/), t.hour))
  g.m = _.cache(_.process(_.rtoken(/^([0-5][0-9]|[0-9])/), t.minute))
  g.mm = _.cache(_.process(_.rtoken(/^[0-5][0-9]/), t.minute))
  g.s = _.cache(_.process(_.rtoken(/^([0-5][0-9]|[0-9])/), t.second))
  g.ss = _.cache(_.process(_.rtoken(/^[0-5][0-9]/), t.second))

  # cpbotha: changed following regular expression so it can also
  # parse isoformat microseconds, e.g. 2012-05-09T23:46:00.123456+02:00
  # it simply consumes the fractional millisecond part.
  #g.fff = _.cache(_.process(_.rtoken(/^[0-9]{3}(?!\d)/), t.millisecond));
  g.fff = _.cache(_.process(_.rtoken(/^([0-9]{3})(\d{3})?/), t.millisecond))
  g.hms = _.cache(_.sequence([g.H, g.m, g.s], g.timePartDelimiter))

  # _.min(1, _.set([ g.H, g.m, g.s ], g._t));
  g.t = _.cache(_.process(g.ctoken2("shortMeridian"), t.meridian))
  g.tt = _.cache(_.process(g.ctoken2("longMeridian"), t.meridian))
  g.z = _.cache(_.process(_.rtoken(/^(Z|z)|((\+|\-)\s*\d\d\d\d)|((\+|\-)\d\d(\:?\d\d)?)/), t.timezone))
  g.zzz = _.cache(_.process(g.ctoken2("timezone"), t.timezone))
  g.timeSuffix = _.each(_.ignore(g.whiteSpace), _.set([g.tt, g.zzz]))
  g.time = _.each(_.optional(_.ignore(_.stoken("T"))), g.hms, g.timeSuffix)

  # days, months, years
  g.d = _.cache(_.process(_.each(_.rtoken(/^([0-2]\d|3[0-1]|\d)/), _.optional(g.ctoken2("ordinalSuffix"))), t.day))
  g.dd = _.cache(_.process(_.each(_.rtoken(/^([0-2]\d|3[0-1])/), _.optional(g.ctoken2("ordinalSuffix"))), t.day))
  g.ddd = g.dddd = _.cache(_.process(g.ctoken("sun mon tue wed thu fri sat"), (s) ->
    ->
      @weekday = s
  ))
  g.M = _.cache(_.process(_.rtoken(/^(1[0-2]|0\d|\d)/), t.month))
  g.MM = _.cache(_.process(_.rtoken(/^(1[0-2]|0\d)/), t.month))
  g.MMM = g.MMMM = _.cache(_.process(g.ctoken("jan feb mar apr may jun jul aug sep oct nov dec"), t.month))
  g.y = _.cache(_.process(_.rtoken(/^(\d\d?)/), t.year))
  g.yy = _.cache(_.process(_.rtoken(/^(\d\d)/), t.year))
  g.yyy = _.cache(_.process(_.rtoken(/^(\d\d?\d?\d?)/), t.year))
  g.yyyy = _.cache(_.process(_.rtoken(/^(\d\d\d\d)/), t.year))

  # rolling these up into general purpose rules
  _fn = ->
    _.each _.any.apply(null, arguments), _.not(g.ctoken2("timeContext"))

  g.day = _fn(g.d, g.dd)
  g.month = _fn(g.M, g.MMM)
  g.year = _fn(g.yyyy, g.yy)

  # relative date / time expressions
  g.orientation = _.process(g.ctoken("past future"), (s) ->
    ->
      @orient = s
  )
  g.operator = _.process(g.ctoken("add subtract"), (s) ->
    ->
      @operator = s
  )
  g.rday = _.process(g.ctoken("yesterday tomorrow today now"), t.rday)
  g.unit = _.process(g.ctoken("second minute hour day week month year"), (s) ->
    ->
      @unit = s
  )
  g.value = _.process(_.rtoken(/^\d\d?(st|nd|rd|th)?/), (s) ->
    ->
      @value = s.replace(/\D/g, "")
  )
  g.expression = _.set([g.rday, g.operator, g.value, g.unit, g.orientation, g.ddd, g.MMM])

  # pre-loaded rules for different date part order preferences
  _fn = ->
    _.set arguments, g.datePartDelimiter

  g.mdy = _fn(g.ddd, g.month, g.day, g.year)
  g.ymd = _fn(g.ddd, g.year, g.month, g.day)
  g.dmy = _fn(g.ddd, g.day, g.month, g.year)
  g.date = (s) ->
    $C = Date.getCultureInfo()
    (g[$C.dateElementOrder] or g.mdy).call this, s


  # parsing date format specifiers - ex: "h:m:s tt"
  # this little guy will generate a custom parser based
  # on the format string, ex: g.format("h:m:s tt")

  # translate format specifiers into grammar rules
  g.format = _.process(_.many(_.any(_.process(_.rtoken(/^(dd?d?d?|MM?M?M?|yy?y?y?|hh?|HH?|mm?|ss?|fff|tt?|zz?z?)/), (fmt) ->
    if g[fmt]
      g[fmt]
    else
      throw $D.Parsing.Exception(fmt)

  # translate separator tokens into token rules
  # all legal separators
  ), _.process(_.rtoken(/^[^dMyhHmsftz]+/), (s) ->
    _.ignore _.stoken(s)

  # construct the parser ...
  ))), (rules) ->
    _.process _.each.apply(null, rules), t.finishExact
  )
  _F = {}

  #"M/d/yyyy": function (s) {
  #    var m = s.match(/^([0-2]\d|3[0-1]|\d)\/(1[0-2]|0\d|\d)\/(\d\d\d\d)/);
  #    if (m!=null) {
  #        var r =  [ t.month.call(this,m[1]), t.day.call(this,m[2]), t.year.call(this,m[3]) ];
  #        r = t.finishExact.call(this,r);
  #        return [ r, "" ];
  #    } else {
  #        throw new Date.Parsing.Exception(s);
  #    }
  #}
  #"M/d/yyyy": function (s) { return [ new Date(Date._parse(s)), ""]; }
  _get = (f) ->
    _F[f] = (_F[f] or g.format(f)[0])

  g.formats = (fx) ->
    if fx instanceof Array
      rx = []
      i = 0

      while i < fx.length
        rx.push _get(fx[i])
        i++
      _.any.apply null, rx
    else
      _get fx


  # check for these formats first
  g._formats = g.formats(["\"yyyy-MM-ddTHH:mm:ss.fffz\"", "yyyy-MM-ddTHH:mm:ss.fffz", "yyyy-MM-ddTHH:mm:ss.fff", "yyyy-MM-ddTHH:mm:ssz", "yyyy-MM-ddTHH:mm:ss", "yyyy-MM-ddTHH:mmz", "yyyy-MM-ddTHH:mm", "yyyy-MM-dd", "ddd, MMM dd, yyyy H:mm:ss tt", "ddd MMM d yyyy HH:mm:ss zzz", "MMddyyyy", "ddMMyyyy", "Mddyyyy", "ddMyyyy", "Mdyyyy", "dMyyyy", "yyyy", "Mdyy", "dMyy", "d"])

  # starting rule for general purpose grammar
  g._start = _.process(_.set([g.date, g.time, g.expression], g.generalDelimiter, g.whiteSpace), t.finish)

  # real starting rule: tries selected formats first,
  # then general purpose rule
  g.start = (s, o) ->
    try
      r = g._formats.call({}, s)
      return r  if r[1].length is 0
    o = {}  unless o
    o.input = s
    g._start.call o, s

  $D._parse = $D.parse

  ###
  Converts the specified string value into its JavaScript Date equivalent using CultureInfo specific format information.

  Example
  <pre><code>
  ///////////
  // Dates //
  ///////////

  // 15-Oct-2004
  var d1 = Date.parse("10/15/2004");

  // 15-Oct-2004
  var d1 = Date.parse("15-Oct-2004");

  // 15-Oct-2004
  var d1 = Date.parse("2004.10.15");

  //Fri Oct 15, 2004
  var d1 = Date.parse("Fri Oct 15, 2004");

  ///////////
  // Times //
  ///////////

  // Today at 10 PM.
  var d1 = Date.parse("10 PM");

  // Today at 10:30 PM.
  var d1 = Date.parse("10:30 P.M.");

  // Today at 6 AM.
  var d1 = Date.parse("06am");

  /////////////////////
  // Dates and Times //
  /////////////////////

  // 8-July-2004 @ 10:30 PM
  var d1 = Date.parse("July 8th, 2004, 10:30 PM");

  // 1-July-2004 @ 10:30 PM
  var d1 = Date.parse("2004-07-01T22:30:00");

  ////////////////////
  // Relative Dates //
  ////////////////////

  // Returns today's date. The string "today" is culture specific.
  var d1 = Date.parse("today");

  // Returns yesterday's date. The string "yesterday" is culture specific.
  var d1 = Date.parse("yesterday");

  // Returns the date of the next thursday.
  var d1 = Date.parse("Next thursday");

  // Returns the date of the most previous monday.
  var d1 = Date.parse("last monday");

  // Returns today's day + one year.
  var d1 = Date.parse("next year");

  ///////////////
  // Date Math //
  ///////////////

  // Today + 2 days
  var d1 = Date.parse("t+2");

  // Today + 2 days
  var d1 = Date.parse("today + 2 days");

  // Today + 3 months
  var d1 = Date.parse("t+3m");

  // Today - 1 year
  var d1 = Date.parse("today - 1 year");

  // Today - 1 year
  var d1 = Date.parse("t-1y");


  /////////////////////////////
  // Partial Dates and Times //
  /////////////////////////////

  // July 15th of this year.
  var d1 = Date.parse("July 15");

  // 15th day of current day and year.
  var d1 = Date.parse("15");

  // July 1st of current year at 10pm.
  var d1 = Date.parse("7/1 10pm");
  </code></pre>

  @param {String}   The string value to convert into a Date object [Required]
  @param {Object}   An object with any defaults for parsing [Optional]
  @return {Date}    A Date object or null if the string cannot be converted into a Date.
  ###
  $D.parse = (s, o) ->
    r = null
    return null  unless s
    return s  if s instanceof Date
    o = {}  unless o
    try
      r = $D.Grammar.start.call({}, s.replace(/^\s*(\S*(\s+\S+)*)\s*$/, "$1"), o)
    catch e
      return null
    (if (r[1].length is 0) then r[0] else null)

  $D.getParseFunction = (fx) ->
    fn = $D.Grammar.formats(fx)
    (s) ->
      r = null
      try
        r = fn.call({}, s)
      catch e
        return null
      (if (r[1].length is 0) then r[0] else null)


  ###
  Converts the specified string value into its JavaScript Date equivalent using the specified format {String} or formats {Array} and the CultureInfo specific format information.
  The format of the string value must match one of the supplied formats exactly.

  Example
  <pre><code>
  // 15-Oct-2004
  var d1 = Date.parseExact("10/15/2004", "M/d/yyyy");

  // 15-Oct-2004
  var d1 = Date.parse("15-Oct-2004", "M-ddd-yyyy");

  // 15-Oct-2004
  var d1 = Date.parse("2004.10.15", "yyyy.MM.dd");

  // Multiple formats
  var d1 = Date.parseExact("10/15/2004", ["M/d/yyyy", "MMMM d, yyyy"]);
  </code></pre>

  @param {String}   The string value to convert into a Date object [Required].
  @param {Object}   The expected format {String} or an array of expected formats {Array} of the date string [Required].
  @return {Date}    A Date object or null if the string cannot be converted into a Date.
  ###
  $D.parseExact = (s, fx) ->
    $D.getParseFunction(fx) s
)()
