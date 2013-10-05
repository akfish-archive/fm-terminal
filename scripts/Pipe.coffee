window.PipeBaseClass = class PipeBase 
        dispatch: (msg) ->
                console.log("Msg on pipe #{@name}:")
                console.log(msg)

        post: (msg) ->
                @port.postMessage(msg)

        
window.PipeClientClass = class PipeClient extends PipeBase
        constructor: (@name) ->
                console.log("Init Pipe Client #{@name}")
                @port = chrome.runtime.connect({name: @name})
                @port.onMessage.addListener (msg) => @dispatch(msg)
                        

window.PipeServerClass = class PipeServer extends PipeBase
        constructor: (@name) ->
                chrome.runtime.onConnect.addListener (port) =>
                        console.log("Init Pipe Server #{@name}")
                        if port.name == @name
                                console.log "Conected pipe: #{@name}"
                                console.log port.sender
                                @port = port
                                @port.onMessage.addListener (msg) => @dispatch(msg)


