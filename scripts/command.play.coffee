class PlayCommand extends window.CommandBase
        execute: (channel_id) ->
                @echo "Play channel #{channel_id}"

(new PlayCommand("play", "Format: play <channel_id>. Play a channel.")).register()
