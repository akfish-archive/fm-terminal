$ ->
        class Terminal
                constructor: (options) ->
                        $('body').terminal(@interpret, options)
                interpret: (command, term) ->
                        if command == "test"
                                term.echo "Test"
                        else
                                term.echo "WTF?"
        
        new Terminal({ prompt: '>', name: 'test' })                
        

