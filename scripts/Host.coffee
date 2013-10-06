window.Pipe = new window.PipeServerClass(pipe_name)

# make sure this file is included after terminal.js
# then the window.T should be overrided 
class TerminalProxy 
        constructor: (@server_pipe) ->


        onCommand: (command) ->
                @t.exec(command)
                
        bind: (@t) ->
                @server_pipe.registerRPC("command", @onCommand.bind(@))
                window.T = @


        echo: (msg...) ->
                @server_pipe.fireRPC "echo", msg...
        set_prompt: (prompt...) ->
                 
        pause: () ->

        resume: () ->

        clear: () -> 

window.TerminalProxy ?= new TerminalProxy(window.Pipe)




