class JsonObject
        constructor: (@json) ->
                for key, value of json
                        @[key] = value
                

class Channel extends JsonObject
        appendSongs: (newSongs) ->
                if not newSongs?
                        return
                @songs ?= []
                # TODO: check max size and release
                @songs = @songs.concat(newSongs)
                return
                
        update: (succ, err, action, sid, history) ->
                window.DoubanFM?.doGetSongs(
                        @,
                        action, sid, history,
                        ((json) =>
                                # TODO: append song list instead of replacing
                                @appendSongs(new Song(s) for s in json?.song)
                                succ?(@songs)
                        )
                                ,
                        err
                )

        
class Song extends JsonObject
        # not so logic, it get liked/unliked/booed/skipped
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

        encodePayload: (payload) ->
                pairs = []
                for k, v of payload
                        pairs.push(k + "=" + v)
                str = pairs.join("&")
                return $.base64.encode(str)
                
        query: (type, url, payload, succ, err) ->
                encoded = @encodePayload(payload)
                encoded_payload = {
                        'url': url,
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
                

window.Service ?= new Service(proxy_domain)

class Player
        constructor: () ->
                @sounds = {}
                # Actions
                @action = {}
                @action.END = "e"
                @action.NONE = "n"
                @action.BOO = "b"
                @action.LIKE = "r"
                @action.UNLIKE = "u"
                @action.SKIP = "s"
                
                @maxHistoryCount = 15
                
                @currentSongIndex = -1

                @looping = false
                                
                soundManager.setup({
                        url: "SoundManager2/swf/",
                        preferFlash: false,

                        onready: () ->
                                window.T?.echo("Player initialized");
                        ontimeout: () ->
                                window.T?.error("Failed to intialize player. Check your brower's flash setting.")
                });

        bind: (div) ->
                @$ui = $(div)

        onLoading: () ->
                #@$ui.text("Loading.. #{@current.bytesLoaded / @current.bytesTotal * 100}")

        formatTime: (ms) ->
                zeroPad = (num, places) ->
                        zero = places - num.toString().length + 1
                        Array(+(zero > 0 && zero)).join("0") + num

                s = Math.floor(ms / 1000)
                MS = ms - s * 1000
                MM = Math.floor(s / 60)
                SS = s - MM * 60
                return "#{zeroPad(MM, 2)}:#{zeroPad(SS, 2)}"

        onPlaying: (pos) ->
                barCount = 30

                playing = not @currentSound.paused
                buffering = @currentSound.isBuffering

                # playing progress
                pos = @currentSound.position
                duration = @currentSound.duration
                play_percent = pos / duration

                # loading progress
                loaded_percent = @currentSound.bytesLoaded / @currentSound.bytesTotal
                load_slider_pos = Math.floor(barCount * loaded_percent)

                play_slider_pos = Math.floor(barCount * play_percent)

                # format
                hl_format = "[gb;#2ecc71;#000]"
                nm_format = "[gb;#fff;#000]"
                no_format = "[gb;#000;#000]"

                # slider

                left = $.terminal.escape_brackets(if @looping then ">" else "[")
                right = $.terminal.escape_brackets(if @looping then "<" else "]")

                border_left = "[#{nm_format}#{left}]"
                border_right = "[#{nm_format}#{right}]"

                empty_bar = "[#{no_format}=]"
                load_slider = "[#{nm_format}☁]"
                loaded_bar = "[#{nm_format}=]"
                play_slider = "[#{hl_format}#{if playing then "♫" else "♨"}]"
                played_bar = "[#{hl_format}#{if playing then ">" else "|"}]"
                
                # Total bar
                barArray = Array(barCount)
                for i in [0..barCount - 1]
                        barArray[i] = empty_bar
                for i in [play_slider_pos..load_slider_pos - 1]
                        barArray[i] = loaded_bar
                for i in [0..play_slider_pos - 1]
                        barArray[i] = played_bar

                barArray[load_slider_pos] = load_slider
                barArray[play_slider_pos] = play_slider

                bar_middle = barArray.join("")

                # display
                time_played = "[#{nm_format}#{@formatTime(pos)}]"
                time_total = "[#{nm_format}#{@formatTime(duration)}]"
                bar_str = "#{time_played}#{border_left}#{bar_middle}#{border_right}#{time_total}"

                bar = $.terminal.format(bar_str)
                @$ui.text("")
                @$ui.append(bar)

        play: (channel) ->
                # if playing then stop
                @stop()
                @startPlay(channel)

        stop: () ->
                @currentSound?.unload()
                @currentSound?.stop()

        pause: () ->
                @currentSound?.pause()
                @onPlaying(@currentSound.position)

        resume: () ->
                @currentSound?.resume()        

        loops: () ->
                console.log("Should loop")
                @looping = not @looping
                        

        startPlay: (channel) ->
                @currentChannel = channel

                # initialize
                @currentSongIndex = -1
                @currentSong = null
                @history = []

                @nextSong(@action.NONE)
        
        getHistory: () ->
                str = "|"
                H = $(@history).map (i, h) ->
                        h.join(":")
                str += H.get().join("|")
                return str
                
        nextSong: (action) ->
                @stop()

                sid = ""
                if @currentSong
                        sid = @currentSong.sid
                        h = [sid, action]
                        # slice to make sure the size 
                        if @history.length > @maxHistoryCount
                                @history = @history[1..]
                        @history.push(h)
                        console.log @getHistory()
                        
                # TODO: record history
                # if not in cache, update
                if (@currentSongIndex + 1 >= @currentChannel.songs.length)
                        # TODO: prompt user that we are updating
                        @currentChannel.update(
                                (songs) => @nextSong(action),
                                () -> #TODO:,
                                action,
                                sid,
                                @getHistory())
                        return # block operation here
                # handle action of previous song
                # action could be booo, finish, skip, null
                if (@currentSongIndex > -1)
                        @currentChannel.update(null, null, action, sid, @getHistory())
                # get next song
                @currentSongIndex++

                # do simple indexing, since when channel is updated, song list is appended
                @doPlay(@currentChannel.songs[@currentSongIndex])
                
        doPlay: (song) ->
                id = song.sid
                url = song.url
                artist = song.artist
                title = song.title
                album = song.albumtitle
                picture = song.picture
                like = song.like != 0
                like_format = if like then "[gb;#f00;#000]" else "[gb;#fff;#000]"
                #window.T.clear()
                window.T.echo "[#{like_format}♥ ][[gb;#e67e22;#000]#{song.artist} - #{song.title} | #{song.albumtitle}]"

                @currentSong = song
                @currentSound = @sounds[id]
                window.T.echo("Loading...",
                        {
                                finalize: (div) => @bind(div),
                        })

                @currentSound ?= soundManager.createSound({
                        url: url,
                        autoLoad: true,
                        whileloading: () => @onLoading(),
                        whileplaying: () => @onPlaying(),
                        onload: () -> @.play()
                        onfinish: () =>
                                if @looping
                                        @doPlay(@currentSong)
                                else
                                        @nextSong(@action.END)
                        # TODO: invoke nextSong when complete
                })
                


        
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
                @player = new Player()
                $(document).ready =>
                        window.T.echo("DoubanFM initialized...")
                        @resume_session()
                
        resume_session: () ->
                # Initialize cookie setting
                $.cookie.json = true
                # read cookie to @user
                cookie_user_json = $.cookie('user')
                @user = if cookie_user_json? then new User(cookie_user_json) else new User()
                # update terminal
                window.TERM.setUser(@user)


        remember: (always) ->
                # calculate expire day
                # see https://github.com/akfish/fm-terminal/edit/develop/douban-fm-api.md#notes-on-expire-field
                now = new Date()
                expire_day = (@user.expire - now.getTime() / 1000) / 3600 / 24
                console.log("Expire in #{expire_day} days")
                
                # session cookie or persistent cookie
                expire = { expires: expire_day }

                # write cookie from @user
                value = @user?.json
                if always
                        $.cookie('user', value, expire)
                else
                        $.cookie('user', value)
                
        forget: () ->
                #TODO: clear cookie
                $.removeCookie('user')

        clean_user_data: () ->
                # TODO: clean user specific data
                # like channels

        post_login: (data, remember, succ, err) ->
                @user = new User(data)
                if (@user.r == 1)
                        err?(@user)
                        return
                @remember(remember)
                @clean_user_data()
                succ?(@user)
                
        login: (email, password, remember, succ, err) ->
                payload =
                {
                        "email": email,
                        "password": password,
                }
                @attachVersion(payload)
                @service.post(
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
                @user = new User()
                @forget()
                @clean_user_data()
                
        #######################################
        # Play Channel
        play: (channel) ->
                @currentChannel = channel
                @player?.play(channel)
        next: () ->
                @player?.nextSong(@player.action.SKIP)

        pause: () ->
                @player?.pause()

        resume: () ->
                @player?.resume()

        loops: () ->
                @player?.loops()

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
                
        doGetSongs: (channel, action, sid, history, succ, err)->
                payload = {
                        "sid": sid,
                        "channel": channel.channel_id ? 0,
                        "type": action ? "n",
                        "h": history ? ""
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
