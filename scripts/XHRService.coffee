class XHRService
        constructor: () ->

        encodePayload: (payload) ->
                pairs = []
                for k, v of payload
                        pairs.push(k + "=" + v)
                str = pairs.join("&")
                return str


        query: (type, url, payload, succ, err) ->
                xhr = new XMLHttpRequest()
                data = null
                if type == "GET"
                        url += "?" + @encodePayload(payload)
                else
                        data = @encodePayload(payload)
                        xhr.setRequestHeader("Content-length", data.length);
                        
                xhr.onreadystatechange = () ->
                        if xhr.readyState == 4
                                if xhr.status == 200
                                        data = JSON.parse(xhr.responseText)
                                        succ(data)
                                else
                                        err(xhr.status, "Error")
                xhr.open(type, url, true)
                xhr.send(data)

        get: (url, data, succ, err) ->
                @query("GET", url, data, succ, err)

        post: (url, data, succ, err) ->
                @query("GET", url, data, succ, err)
                

window.Service ?= new XHRService()
