# Date.js #
I noticed some missing translations and thought about adding them, but saw that eric's last changes were made 5 months ago. So, here goes a fork with many other forks merged in. I'm not entirely sure if I just completely broke it.

The original code was released by Coolite, then modified by many contributors at GitHub.

## Changes ##
* The project files are now written in CoffeeScript for easier reading and compiling.

## Usage ##

## License ##
The MIT License (http://www.opensource.org/licenses/mit-license.php)

Copyright (c) 2006-2008 Coolite Inc. (http://www.coolite.com/)

Copyright (c) 2011-2013 [GitHub contributors] (https://github.com/kriswema/Datejs/contributors)

# eric's README.md #

## What's the deal with this fork? ##

I've ran into some issues with parsing and maintainability. The latest commit
to date.js was in 2008 and there hasn't been a response to any of my inquiries.

I started off making branches with pull requests for the individual changes I
had, but all of my changes have ended up relying on the previous change.

Because of this, I have settled on using the `next` branch to contain all of
my changes.


## What have you changed? ##

This isn't a comprehesive list, but it hopefully will hit the high points.

* Make tests runnable from the command line via node.js
* Make all tests pass via command line (this means marking some tests as failing)
* Adding comments to `finish()` in `parser.js` to describe what each condition does
* Remove conditions in `finish()` in `parser.js` that are not used by any tests
* Fix a couple relative-ish cases like `15th at 3pm`
* Added support for "biasing" toward dates in the past or the future
* Added support for load multiple locale files
* Added support for switch between locales (with Date.setLocale) and for single instance

## Biasing ##

There are many times where your users will be tending to want to specify dates
only in the past or the future, so providing a mechanism where, if it is
`3pm` in the afternoon, specifying `1pm` would give you the next day instead
of the current one.

To enable biasing, `Date.parse()` now takes an optional object that is used
as the object that is parsed to set defaults.

To enable biasing, set the `bias` property to either `past` or `future`. For
example:

  ```javascript
    Date.parse('3pm', { bias: 'future' })
  ```


## Original README.txt ##

For a quick tutorial on getting started with Datejs, please visit the following links...

http://www.datejs.com/2007/11/27/getting-started-with-datejs/

http://code.google.com/p/datejs/

Hope this helps!
