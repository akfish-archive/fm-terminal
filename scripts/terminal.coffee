
greet = (callback) ->
        str =  "[[gb;#ffffff;#000]CatX.FM 猫杀电台\r\n]"
        str += "[[;#e67e22;]music provided by douban.fm]\r\n"
        str += "Type [[ub;#2ecc71;#000]channel] to discovery music, or "
        str += "[[ub;#2ecc71;#000]help] for full command list\r\n"
        str += "[[gb;#929292;#000]......]"
        return str

class CommandBase
        constructor: (name, desc) ->
                @name = name
                @desc = desc
        echo: (msg) ->
                window.T?.echo msg
                return
        register: () ->
                window.TERM?.registerCommand(@name, @)
        execute: () ->
                @echo "Command Base"
                return
        getHelpString: () ->
                len = @name.length
                padding = Array(10 - len).join " " 
                return "[[ub;#2ecc71;#000]#{@name}]#{padding}#{@desc}"

        on_error: (status, error) ->
                window.T.resume()
                @echo "Status: #{status}"
                @echo "Error: #{error}"
                @echo "Error, try again later"
                return
                

window.CommandBase ?= CommandBase

class HelpCommand extends CommandBase
        constructor: (name, desc) ->
                super(name, desc)
                window.Help ?= @
                
        execute: () ->
                @echo "[[b;;]Available Commands]"
                @echo "--------------------------------"                
                for name, cmd of window.commands
                        @echo cmd.getHelpString()
                @echo "--------------------------------"
                return

        completion: (term, str, cb) ->
                cb(name for name, cmd of window.commands)
                return

        errorMessage: (cmd) ->
                @echo "[[gb;#e67e22;#000]Unknown command:] [[gub;#e67e22;#000]#{cmd}]"
                @echo "Type [[ub;#2ecc71;#000]help] for command list"

prompt = "♫>"                
class Terminal
        setUser: (user) ->
                name = user?.user_name ? ""
                name_str = if name != "" then "[#{name}]" else ""
                window.T?.set_prompt(name_str + prompt)
                
        constructor: () ->
                window.commands ?= {}
        start: (options) ->
                t = $('body').terminal(@interpret, options)
                if window.TerminalProxy?
                        window.TerminalProxy.bind(t)
                window.T ?= t
                window.T.UI = new window.PlayerUI(t)
                return

        interpret: (name, term) ->
                term.echo "[[gb;#929292;#000]...]"
                parse = $.terminal.parseCommand(name)
                # window.T ?= term
                commands = window.commands
                if commands? and commands[parse.name]?
                        cmd = commands[parse.name]
                        cmd.execute.apply cmd, parse.args
                else
                        window.Help?.errorMessage name
                term.echo "[[gb;#929292;#000]...]"
                return
                
        registerCommand: (name, command) ->
                window.commands[name] = command
                return
                

window.TERM ?= new Terminal()
(new HelpCommand "help", "Show help").register()

jQuery(document).ready ->
        window.TERM.start({
                prompt: prompt,
                name: 'catx.fm',
                greetings: greet,
                history: true,
                tabcompletion: true,
                completion: window.Help.completion,
                })                
        
        
