class PlayCommand extends window.CommandBase
        play: (channel) ->
                window.DoubanFM.play(channel)
                                
        listSongs: () ->
                console.log "List songs"
                # TODO: don't do update here, the player will handle that
                if @channel.songs?
                        @play(@channel)
                else
                        @channel.update(
                                (songs) => @play(@channel),
                                (status, error) => @on_error
                        )
                        
        playChannel: (channel_id) ->
                @channel = window.DoubanFM?.channels?[channel_id]
                if not @channel?
                        @echo "Unknown channel #{channel_id}"
                else
                        @echo "Play channel #{channel_id}.#{@channel.name}"
                        @listSongs()
                window.T.resume()
                
        execute: (channel_id) ->
                #Check if channel is valid
                if window.DoubanFM.channels?
                        @playChannel(channel_id)
                else
                        @echo "Requesting..."
                        window.T.pause()
                        window.DoubanFM.update(
                                (channels) => @playChannel(channel_id),
                                (status, error) => @on_error(status, error)
                        )

(new PlayCommand("play", "Format: play <channel_id>. Play a channel.")).register()
