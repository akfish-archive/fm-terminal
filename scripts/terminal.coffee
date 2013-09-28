jQuery(document).ready ->

        greet = (callback) ->
                str =  "[[gb;#ffffff;#000]CatX.FM 猫杀电台\r\n]"
                str += "[[;#e67e22;]music provided by douban.fm]"
                return str

        class Terminal
                constructor: (options) ->
                        $('body').terminal(@interpret, options)
                interpret: (command, term) ->
                        if command == "test"
                                term.echo "Test"
                        else
                                term.echo "WTF?"
                        return
        
        new Terminal({ prompt: '>', name: 'test', greetings: greet })                
        
