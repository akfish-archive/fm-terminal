class JSONPService
        constructor: (@proxy) ->

        encodePayload: (payload) ->
                pairs = []
                for k, v of payload
                        pairs.push(k + "=" + v)
                str = pairs.join("&")
                return $.base64.encode(str)
                
        query: (type, url, payload, succ, err) ->
                encoded = @encodePayload(payload)
                encoded_payload = {
                        'url': $.base64.encode(url),
                        'payload': encoded
                }

                console.log "#{type} #{url}"
                console.log "Payload: "
                console.log payload
                console.log "Encoded: "
                console.log encoded_payload
                console.log "Decoded: "
                console.log $.base64.decode(encoded)
                
                $.jsonp({
                        type: type,
                        data: encoded_payload,
                        url: @proxy + "?callback=?",
                        
                        xhrFields: {
                                withCredentials: false
                        },
                        success: (data) -> succ(data)
                                ,
                        error: (j, status, error) -> err(status, error)
                })

        get: (url, data, succ, err) ->
                @query("GET", url, data, succ, err)

        post: (url, data, succ, err) ->
                @query("POST", url, data, succ, err)
                

window.Service ?= new JSONPService(proxy_domain)
