class JsonObject
        constructor: (@json) ->
                for key, value of json
                        @[key] = value
                

class Channel extends JsonObject

        update: (succ, err) ->
                window.DoubanFM?.doGetSongs(
                        @,
                        ((json) =>
                                @songs = (new Song(s) for s in json?.song)
                                succ(@songs)
                        )
                                ,
                        err
                )

        
class Song extends JsonObject
        like: () ->
                window.DoubanFM?.doLike(@)

        unlike: () ->
                window.DoubanFM?.doUnlike(@)
                
        boo: () ->
                window.DoubanFM?.doBoo(@)
                
        skip: () ->
                window.DoubanFM?.doSkip(@)

class User extends JsonObject
        attachAuth: (data) ->
                data["user_id"] = @user_id if @user_id?
                data["token"] = @token if @token?
                data["expire"] = @expire if @expire?

class Service
        constructor: (@proxy) ->

        query: (type, url, data, succ, err) ->
                data['url'] = url
                console.log "#{type} #{url}"
                console.log "Data: "
                console.log data
                $.jsonp({
                        type: type,
                        data: data,
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
                
#proxy_domain = "http://localhost:10080"
proxy_domain = "https://jsonpwrapper.appspot.com"

window.Service ?= new Service(proxy_domain)

class DoubanFM
        app_name = "radio_desktop_win"
        version = 100
        domain = "http://www.douban.com"
        login_url = "/j/app/login"
        channel_url = "/j/app/radio/channels"
        song_url = "/j/app/radio/people"

        attachVersion: (data) ->
                data["app_name"] = app_name
                data["version"] = version
        
        constructor: (@service) ->
                window.DoubanFM ?= @
                @resume()
                
        resume: () ->
                #TODO: read cookie to @user

        remember: () ->
                #TODO: write cookie from @user
                
        forget: () ->
                #TODO: clear cookie

        post_login: (data, remember, succ, err) ->
                @user = new User(data)
                if (@user.r == 1)
                        err(@user)
                        return
                if (remember)
                        @remember
                succ(@user)
                
        login: (email, password, remember, succ, err) ->
                payload =
                {
                        "email": email,
                        "password": password,
                }
                @attachVersion(payload)
                @service.get(
                        domain + login_url,
                        payload,
                        ((data) =>
                                @post_login(data, remember, succ, err)
                        ),
                        ((status, error) =>
                                data = { r: 1, err: "Internal Error: #{error}" }
                                @post_login(data, remember, succ, err)
                        ))
                return
                
        logout: () ->
                @User = new User()
                @forget()

        #######################################
        #
        update: (succ, err) ->
                @doGetChannels(
                        ((json) =>
                                @channels = (new Channel(j) for j in json?.channels)
                                succ(@channels)
                        )
                                ,
                        err
                )
                

        #######################################
        doGetChannels: (succ, err)->
                @service.get(
                        domain + channel_url,
                        {},
                        succ,
                        err)        
                
        doGetSongs: (channel, succ, err)->
                payload = {
                        "sid": "",
                        "channel": channel.channel_id ? 0,
                        "type": "n"
                }
                @attachVersion(payload)
                @user?.attachAuth(payload)

                @service.get(
                        domain + song_url,
                        payload,
                        succ,
                        err
                )

        #######################################
        doLike: (song) ->
                #TODO:

        doUnlike: (song) ->
                #TODO:
                
        doBoo: (song) ->
                #TODO:

        doSkip: (song) ->
                #TODO:

new DoubanFM(window.Service)
