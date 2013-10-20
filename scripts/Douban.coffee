class JsonObject
        constructor: (@json) ->
                for key, value of json
                        @[key] = value
                

class Channel extends JsonObject
        isAd: (song) ->
                sid = song.sid
                # The sid of ad is something like: da60222_43
                return sid.indexOf("_") != -1

        appendSongs: (newSongs) ->
                if not newSongs?
                        return

                realSongs = []
                for song in newSongs
                        if not @isAd(song)
                                realSongs.push song
                        else
                                console.log "Filter ad:"
                                console.log song
                                
                @songs ?= []
                # TODO: check max size and release
                @songs = @songs.concat(realSongs)
                return
                
        update: (succ, err, action, sid, history) ->
                window.DoubanFM?.doGetSongs(
                        @,
                        action, sid, history,
                        ((json) =>
                                # TODO: append song list instead of replacing
                                if json?.song?
                                        @appendSongs(new Song(s) for s in json?.song)
                                succ?(@songs)
                        )
                                ,
                        err
                )

        
class Song extends JsonObject


class User extends JsonObject
        attachAuth: (data) ->
                data["user_id"] = @user_id if @user_id?
                data["token"] = @token if @token?
                data["expire"] = @expire if @expire?


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
                @frontMostSongIndex = -1
                
                @looping = false
                                
                soundManager.setup({
                        url: "SoundManager2/swf/",
                        preferFlash: false,
                        debugMode: false,
                        onready: () ->
                                window.T?.echo("Player initialized");
                                window.DoubanFM.player.vol = $.cookie("vol") ? 80

                        ontimeout: () ->
                                window.T?.error("Failed to intialize player. Check your brower's flash setting.")
                });

        currentSoundInfo: () ->
                sound = {}

                sound.song = @currentSong
                
                sound.paused = @currentSound.paused
                sound.isBuffering = @currentSound.isBuffering
                
                sound.position = @currentSound.position
                sound.duration = @currentSound.duration
                sound.bytesLoaded = @currentSound.bytesLoaded
                sound.bytesTotal = @currentSound.bytesTotal

                sound.looping = @looping
                sound.vol = @vol
                sound.muted = soundManager.muted
                return sound
                
        play: (channel) ->
                # if playing then stop
                @stop()
                @startPlay(channel)

        stop: () ->
                @currentSound?.unload()
                @currentSound?.stop()

        pause: () ->
                @currentSound?.pause()
                window.T.update_ui(@currentSoundInfo())


        resume: () ->
                @currentSound?.resume()        

        loops: () ->
                console.log("Should loop")
                @looping = not @looping

        mute: () ->
                if soundManager.muted
                        soundManager.unmute()
                else
                        soundManager.mute()

        setVol: (vol) ->
                @vol = vol
                # Expire in 10 years, like forever
                $.cookie("vol", @vol, { expires: 3650 })
                soundManager.setVolume(@currentSound?.id, @vol)

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

        updateHistory: (action) ->
                # No history for NONE
                if action == @action.NONE
                        return
                if @currentSong
                        # No sid for END
                        sid = if action == @action.END then "" else @currentSong.sid
                        
                        h = [sid, action]
                        # slice to make sure the size 
                        if @history.length > @maxHistoryCount
                                @history = @history[1..]
                        @history.push(h)
                        console.log @getHistory()
                
        isCacheNeeded: (callback) ->
                sid = @currentSong?.sid ? ""
                if (@currentSongIndex + 1 >= @currentChannel.songs.length)
                        # TODO: prompt user that we are updating
                        @currentChannel.update(
                                callback,
                                () -> #TODO:,
                                @action.NONE,
                                sid,
                                @getHistory())
                        return true
                return false
        commitAction: (action, succ, err) ->
                # Don't do NONE
                if action == @action.NONE
                        return
                # Non-social operation, just update
                sid = @currentSong?.sid
                if action == @action.END or action == @action.SKIP
                        # Avoid duplication 
                        if (@currentSongIndex == @frontMostSongIndex)
                                @updateHistory(action)
                # Boo, like or unlike
                else
                        @updateHistory(action)
                if not sid?
                        return


                if (@currentSongIndex > -1)
                        @currentChannel.update(succ, err, action, sid, @getHistory())

        # succ and err are for commitAction
        nextSong: (action, succ, err) ->
                @stop()

                sid = @currentSong?.sid ? ""

                # if not in cache, update
                if (@isCacheNeeded((songs) => @nextSong(action, succ, err)))
                        return # block operation here
                
                # handle action of previous song
                # action could be booo, finish, skip, null
                @commitAction action, succ, err

                # get next song
                @currentSongIndex++
                @frontMostSongIndex = Math.max(@frontMostSongIndex, @currentSongIndex)
                
                # do simple indexing, since when channel is updated, song list is appended
                @doPlay(@currentChannel.songs[@currentSongIndex])

        prevSong: () ->
                # No previouse song
                if (@currentSongIndex <= 0)
                        window.T.echo "No previous song..."
                        return 

                @stop()

                # get prev song
                @currentSongIndex--

                # do simple indexing, since when channel is updated, song list is appended
                @doPlay(@currentChannel.songs[@currentSongIndex])
                
        doPlay: (song) ->
                id = song.sid
                url = song.url
                
                @currentSong = song
                @currentSound = @sounds[id]
                window.T.init_ui(song)

                if @onPlayCallback?
                        @onPlayCallback(song)
                @currentSound ?= soundManager.createSound({
                        id: id,
                        url: url,
                        autoLoad: true,
                        volume: @vol,
                        whileloading: () => window.T.update_ui(@currentSoundInfo()),
                        whileplaying: () => window.T.update_ui(@currentSoundInfo()),
                        onload: () -> @.play()
                        onfinish: () =>
                                if @looping
                                        @doPlay(@currentSong)
                                else
                                        @nextSong(@action.END)
                        onsuspend: () =>
                                console.log "Suspended"
                                # @nextSong(@action.END)
                        onconnet: () =>
                                connected = @currentSound.connected
                                if not connected
                                        console.log "Connection failed. Try next song"
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

        isLoggedIn: () ->
                return @user? and @user.user_id? and @user?.user_id != ""
                                
        #######################################
        # Play Channel
        play: (channel) ->
                @currentChannel = channel
                @player?.play(channel)
                
        next: () ->
                @player?.nextSong(@player.action.SKIP)

        onSocialErr: (status, err) ->
                window.T.error "Operation failed: #{status}"

        boo: () ->
                # check login
                if not @isLoggedIn()
                        window.T.error "Need login first"
                        return
                @player?.nextSong(@player.action.BOO,
                        () -> window.T.echo "Done. Will never play again.",
                        (status, err) => @onSocialErr(status, err))

        like: () ->
                # check login
                if not @isLoggedIn()
                        window.T.error "Need login first"
                        return
                # TODO: check like
                @player?.commitAction(@player.action.LIKE,
                        () =>
                                window.T.echo "Liked"
                                @player?.currentSong?.like = 1
                        ,
                        (status, err) => @onSocialErr(status, err))
                
        unlike: () ->
                # check login
                if not @isLoggedIn()
                        window.T.error "Need login first"
                        return
                # TODO: check like
                @player?.commitAction(@player.action.UNLIKE,
                        () =>
                                window.T.echo "Unliked"
                                @player?.currentSong?.like = 0
                        ,
                        (status, err) => @onSocialErr(status, err))

        prev: () ->
                @player?.prevSong()
        pause: () ->
                @player?.pause()

        resume: () ->
                @player?.resume()

        loops: () ->
                @player?.loops()

        stop: () ->
                @player?.stop()

        mute: () ->
                @player?.mute()

        setVol: (vol) ->
                range = parseInt(vol, 10)
                if not range or range < 0 or range > 100
                        window.T?.echo "Current volume: [[gb;#e67e22;#000]#{@player?.vol}]"
                        window.T?.echo "Use [[ub;#2ecc71;#000]vol <range>] to change voluem. <range> must be a number between 0~100"
                        return
                @player?.setVol(range)


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


new DoubanFM(window.Service)
