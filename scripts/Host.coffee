window.Pipe = new window.PipeServerClass(pipe_name)

# make sure this file is included after terminal.js
# then the window.T should be overrided 
class TerminalProxy 
        constructor: (@server_pipe) ->
                @T = window.T
                window.T = @

        echo: (msg...) ->

        set_prompt: (prompt...) ->

        pasue: () ->

        resume: () ->

        clear: () -> 






