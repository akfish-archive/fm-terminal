
greet = (callback) ->
        str =  "[[gb;#ffffff;#000]CatX.FM 猫杀电台\r\n]"
        str += "[[;#e67e22;]music provided by douban.fm]"
        return str

class Terminal

        constructor: () ->
                @commands = {}
        start: (options) ->
                $('body').terminal(@interpret, options)
                
        interpret: (name, term) ->
                commands = window.TERM.commands
                if commands? and commands[name]?
                        commmands[name]()
                else
                        term.echo "WTF?"
                return
        registerCommand: (name, command) ->
                @commands[name] = command

if not window.TERM?
        window.TERM = new Terminal() 

jQuery(document).ready ->
        window.TERM.start({
                prompt: '♫',
                name: 'catx.fm',
                greetings: greet,
                history: true,
                tabcompletion: true
                })                
        
        
