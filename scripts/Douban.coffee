class JsonObject
        constructor: (@json) ->
                for key, value of json
                        @[key] = value
                

class Channel extends JsonObject
        songs: () ->
                window.DoubanFM?.doGetSongs(@)
        
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
        
class Service
        constructor: (@proxy) ->

        get: (url, data, succ, err) ->


        post: (url, data, succ, err) ->



class DoubanFM
        domain = "http://www.douban.com"
        login_url = "/j/app/login"
        channel_url = "/j/app/radio/channels"
        song_url = "/j/app/radio/people"
        
        constructor: (@service) ->
                window.DoubanFM ?= @
                @user = @resume()
                
        resume: () ->
                #TODO:

        login: (user, password, remeber) ->
                #TODO:
                
        logout: () ->
                #TODO:

        #######################################
        # 
        channels: () ->
                return doGetChannels()

        #######################################
        doGetChannels: ()->
                #TODO:
                
        doGetSongs: (channel)->
                #TODO:

        #######################################
        doLike: (song) ->
                #TODO:

        doUnlike: (song) ->
                #TODO:
                
        doBoo: (song) ->
                #TODO:

        doSkip: (song) ->
                #TODO:
