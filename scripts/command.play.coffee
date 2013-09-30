class PlayCommand extends window.CommandBase
        playChannel: (channel_id) ->
                channel = window.DoubanFM?.channels?[channel_id]
                if not channel?
                        @echo "Unknown channel #{channel_id}"
                else
                        @echo "Play channel #{channel_id}.#{channel.name}"
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
