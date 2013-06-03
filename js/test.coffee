messages = ["Nope", "Keep Trying", "Nadda", "Sorry", "No one's home", "Arg", "Bummer", "Faux pas", "Whoops", "Snafu", "Blunder"]
input = $("input.test")
output = $("p.test.output")
output_empty = "…"

output.text output_empty

input.keyup (e) ->
  output.removeClass().addClass 'test output'
  if input.val().length > 0
    date = Date.parse input.val()
    if date isnt null
      input.removeClass().addClass 'test'
      output.addClass 'accept'
      output.text date.toString("dddd, MMMM dd, yyyy h:mm:ss tt")
    else
      input.addClass 'validate_error'
      output.addClass 'error'
      output.text messages[Math.round(messages.length * Math.random())] + '…'
  else
    output.text output_empty
    output.addClass 'empty'
