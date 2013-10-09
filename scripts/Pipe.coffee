window.PipeBaseClass = class PipeBase
        constructor: (@name) ->
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
                console.log("Msg on pipe #{@name}:")
                console.log(msg)
                try
                        @onRPC(msg)
                catch error
                        console.error error

        post: (msg) ->
                @port?.postMessage(msg)

         
window.PipeClientClass = class PipeClient extends PipeBase
        constructor: (name) ->
                super name
                console.log("Init Pipe Client #{@name}")
                @port = chrome.runtime.connect({name: @name})
                @port.onMessage.addListener (msg) => @dispatch(msg)
                        

window.PipeServerClass = class PipeServer extends PipeBase
        constructor: (name) ->
                super name
                chrome.runtime.onConnect.addListener (port) =>
                        console.log("Init Pipe Server #{@name}")
                        if port.name == @name
                                console.log "Conected pipe: #{@name}"
                                console.log port.sender
                                @port = port
                                @port.onMessage.addListener (msg) => @dispatch(msg)


