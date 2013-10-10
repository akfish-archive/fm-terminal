window.Pipe = new window.PipeServerClass(pipe_name)

# make sure this file is included after terminal.js
# then the window.T should be overrided 
class TerminalProxy 
        constructor: (@server_pipe) ->


        onCommand: (command) ->
                @t.exec(command)
                
        bind: (@t) ->
                @server_pipe.registerRPC("do_login", @do_login.bind(@))                
                @server_pipe.registerRPC("command", @onCommand.bind(@))
                @server_pipe.registerRPC("request_user", @request_user.bind(@))                
                window.T = @


        echo: (msg...) ->
                @server_pipe.fireRPC "echo", msg...
        error: (msg...) ->
                @server_pipe.fireRPC "error", msg...
        set_prompt: (prompt...) ->
                @server_pipe.fireRPC "set_prompt", prompt...
        pause: () ->
                @server_pipe.fireRPC "pause"
        resume: () ->
                @server_pipe.fireRPC "resume"
        clear: () -> 
                @server_pipe.fireRPC "clear"

        init_ui: (song...) ->
                @server_pipe.fireRPC "init_ui", song...

        update_ui: (sound...) ->
                @server_pipe.fireRPC "update_ui", sound...
                
        login_begin: () ->
                @server_pipe.fireRPC "login_begin"
                
        login_succ: (user) ->
                @server_pipe.fireRPC "login_succ", user

        login_fail: (user) ->
                @server_pipe.fireRPC "login_fail", user

        # very nasty, fix later
        do_login: (info) ->
                window.DoubanFM?.login(info.username, info.password, info.remember,
                                        (user) => @login_succ(user),
                                        (user) => @login_fail(user))

        request_user: () ->
                @server_pipe.fireRPC "set_user", window.TERM.user
                                                
window.TerminalProxy ?= new TerminalProxy(window.Pipe)

class Notification
        onPlay: (song) ->
                
                notif = webkitNotifications.createNotification(
                        song.picture,
                        "<#{song.albumtitle}> #{song.artist}",
                        song.title)

                notif.show()
                window.setTimeout(
                        () -> notif.cancel(),
                        5000)
                
        constructor: () ->
                window.DoubanFM.player.onPlayCallback = @onPlay.bind(@)

new Notification()

