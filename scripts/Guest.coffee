window.Pipe = new window.PipeClientClass(pipe_name)

greet = (callback) ->
        str =  "[[gb;#ffffff;#000]CatX.FM 猫杀电台\r\n]"
        str += "[[;#e67e22;]music provided by douban.fm]\r\n"
        str += "Type [[ub;#2ecc71;#000]channel] to discovery music, or "
        str += "[[ub;#2ecc71;#000]help] for full command list\r\n"
        str += "[[gb;#929292;#000]......]"
        return str

prompt = "♫>"
class TerminalProxyTarget
        # TODO: register pip dispatch
        # and route to window.T

        echo: (pack) ->
                @t.echo(pack[0], pack[1])
                
        constructor: () ->
                @t = window.T
                @ui = new window.PlayerUI(@t)
                window.T.UI = @ui
                # Incoming
                window.Pipe.registerRPC("echo", @echo.bind(@))
                window.Pipe.registerRPC("error", @t.error.bind(@t))                
                window.Pipe.registerRPC("set_prompt", @t.set_prompt.bind(@t))
                window.Pipe.registerRPC("pause", @t.pause.bind(@t))
                window.Pipe.registerRPC("resume", @t.resume.bind(@t))
                window.Pipe.registerRPC("clear", @t.clear.bind(@t))                

                window.Pipe.registerRPC("init_ui", @t.UI.init.bind(@t.UI))
                window.Pipe.registerRPC("update_ui", @t.UI.update.bind(@t.UI))
                
        # Out going
        
        requestUser: () ->
                window.Pipe.fireRPC "request_user"
        requestPlayerStatus: () ->
                window.Pipe.fireRPC "request_player_status"
        requestCommandList: () ->
                window.Pipe.fireRPC "request_command_list"

class RemoteTerminal
        setUser: (user) ->
                name = user?.user_name ? ""
                name_str = if name != "" then "[#{name}]" else ""
                window.T?.set_prompt(name_str + prompt)

        setCommandList: (list) ->
                @commands = list

        completion: (term, str, cb) ->
                cb(@commands)
                return
                
        constructor: () ->
                window.commands ?= {}
                window.Pipe.registerRPC("set_user", @setUser.bind(@))
                window.Pipe.registerRPC("set_command_list", @setCommandList.bind(@))
                
        start: (options) ->
                _gaq?.push(['_trackEvent', 'terminal', 'start'])
                window.T = $('body').terminal(@interpret, options)
                @proxyTarget = new TerminalProxyTarget()
                @proxyTarget.requestUser()
                @proxyTarget.requestPlayerStatus()
                @proxyTarget.requestCommandList()
                return

        interpret: (name, term) ->
                term.echo "[[gb;#929292;#000]...]"
                window.Pipe.fireRPC("command", name)
                term.echo "[[gb;#929292;#000]...]"
                return
                
        registerCommand: (name, command) ->
                window.commands[name] = command
                return
                

window.TERM ?= new RemoteTerminal()

jQuery(document).ready ->
        window.TERM.start({
                prompt: prompt,
                name: 'catx.fm',
                greetings: greet,
                history: true,
                tabcompletion: true,
                completion: window.TERM.completion.bind(window.TERM),                
                })                
        
        
