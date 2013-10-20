window.PipeBaseClass = class PipeBase
        constructor: (@key) ->
                @rpcMap = {}

        registerRPC: (name, fn) ->
                @rpcMap[name] = fn

        fireRPC: (name, args) ->
                rpc =
                        name:
                                name
                        args:
                                args
                @post rpc

        onRPC: (msg) ->
                if msg.name?
                        @rpcMap[msg.name]?(msg.args)
        
        dispatch: (msg) ->
                console.log("Msg on pipe #{@key}:")
                console.log(msg)
                try
                        @onRPC(msg)
                catch error
                        console.error "Error while dispatching: #{msg.name}"
                        console.error error


         
window.PipeClientClass = class PipeClient extends PipeBase
        constructor: (key) ->
                super key
                @id = (new Date()).getTime()
                @name = "#{key}:#{@id}"
                console.log("Init Pipe Client #{@name}")
                @port = chrome.runtime.connect({name: @name})
                @port.onMessage.addListener (msg) => @dispatch(msg)

        post: (msg) ->
                @port?.postMessage(msg)
                        

window.PipeServerClass = class PipeServer extends PipeBase
        constructor: (name) ->
                super name
                @ports = {}
                chrome.runtime.onConnect.addListener (port) =>
                        console.log("Init Pipe Server #{@key}")
                        [key, id] = port.name.split(":")
                        if key == @key
                                console.log "Conected pipe: #{id}"
                                console.log port.sender
                                @ports[id] = port
                                port.onMessage.addListener (msg) => @dispatch(msg)
                                port.onDisconnect.addListener (port) => @onDisconnect(port)

        onDisconnect: (port) ->
                console.log "OnDisconnect:"
                console.log port
                [key, id] = port.name.split ":"
                if id?
                        console.log("Pipe #{id} disconnected")
                        delete @ports[id]
        post: (msg) ->
                for id, port of @ports
                        port?.postMessage(msg)

