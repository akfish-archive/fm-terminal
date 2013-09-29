
greet = (callback) ->
        str =  "[[gb;#ffffff;#000]CatX.FM 猫杀电台\r\n]"
        str += "[[;#e67e22;]music provided by douban.fm]"
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
                return "[[ub;#2ecc71;#000]#{@name}] \t #{@desc}"

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

        errorMessage: (cmd) ->
                @echo "[[gb;#e67e22;#000]Unknown command:] [[gub;#e67e22;#000]#{cmd}]"
                @echo "Type [[ub;#2ecc71;#000]help] for command list"
                
class Terminal

        constructor: () ->
                window.commands ?= {}
        start: (options) ->
                $('body').terminal(@interpret, options)

        interpret: (name, term) ->
                window.T ?= term
                commands = window.commands
                if commands? and commands[name]?
                        cmd = commands[name]
                        cmd.execute.apply cmd
                else
                        window.Help?.errorMessage name
                return
        registerCommand: (name, command) ->
                window.commands[name] = command

window.TERM ?= new Terminal()
(new HelpCommand "help", "Show help").register()

jQuery(document).ready ->
        window.TERM.start({
                prompt: '♫',
                name: 'catx.fm',
                greetings: greet,
                history: true,
                tabcompletion: true
                })                
        
        
