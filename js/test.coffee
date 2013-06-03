messages = ["Nope", "Keep Trying", "Nadda", "Sorry", "No one's home", "Arg", "Bummer", "Faux pas", "Whoops", "Snafu", "Blunder"]
input = $("input.test")
input_empty = "*Enter a date (or time) here"
output = $("p.test.output")
output_empty = "Type a date above"

input.val input_empty
output.text output_empty

input.keyup (e) ->
  output.removeClass()
  if input.val().length > 0
    date = Date.parse(input.val())
    if date isnt null
      input.removeClass()
      output.addClass("accept").text date.toString("dddd, MMMM dd, yyyy h:mm:ss tt")
    else
      input.addClass "validate_error"
      output.addClass("error").text messages[Math.round(messages.length * Math.random())] + "..."
  else
    output.text = output_empty
    output.addClass "empty"

input.focus (e) ->
  input.val ""  if input.val() is input_empty

input.blur (e) ->
  input.val(input_empty).removeClass()  if input.val() is ""
