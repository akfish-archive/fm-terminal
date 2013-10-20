window.PlayerUI = class PlayerUI
        bind: (div, callback) ->
                @$ui = $(div)
                callback?()

        update: (sound) ->
                if not @$ui?
                        @init(sound.song, () => @update(sound))
                        return
                like = sound.song.like != 0
                like_format = if like then "[gb;#f00;#000]" else "[gb;#fff;#000]"

                heart = "[#{like_format} ♥]"
                barCount = 30

                playing = not sound.paused
                buffering = sound.isBuffering

                # playing progress
                pos = sound.position
                duration = sound.duration
                play_percent = pos / duration

                # loading progress
                loaded_percent = sound.bytesLoaded / sound.bytesTotal
                load_slider_pos = Math.floor(barCount * loaded_percent)

                play_slider_pos = Math.floor(barCount * play_percent)

                # format
                hl_format = "[gb;#2ecc71;#000]"
                nm_format = "[gb;#fff;#000]"
                no_format = "[gb;#000;#000]"

                # slider

                left = $.terminal.escape_brackets(if sound.looping then ">" else "[")
                right = $.terminal.escape_brackets(if sound.looping then "<" else "]")

                border_left = "[#{nm_format}#{left}]"
                border_right = "[#{nm_format}#{right}]"

                empty_bar = "[#{no_format}=]"
                load_slider = "[#{nm_format}☁]"
                loaded_bar = "[#{nm_format}=]"
                play_slider = "[#{hl_format}#{if playing then "♫" else "♨"}]"
                played_bar = "[#{hl_format}#{if playing then ">" else "|"}]"

                # Volumn
                vol_bar = ['▁', '▂', '▃', '▄', '▅']
                vol_count = Math.round(sound.vol / 20) - 1
                if vol_count < 0
                        vol_count = 0
                vol_set_bar = vol_bar[0..vol_count].join("")
                vol_no_set_bar = vol_bar[vol_count + 1..].join("")
                if sound.muted
                        mute_vol = Array(6).join(vol_bar[0])
                        vol = "[#{nm_format}#{mute_vol}]"
                else
                        vol = "[#{hl_format}#{vol_set_bar}][#{nm_format}#{vol_no_set_bar}]"
                vol_bar_str = "#{border_left}#{vol}#{border_right}"
                
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
                bar_str = "#{heart}" +
                        "[#{no_format}=]" +
                        "#{time_played}#{border_left}#{bar_middle}#{border_right}#{time_total}#{vol_bar_str}"

                bar = $.terminal.format(bar_str)
                @$ui.text("")
                @$ui.append(bar)

        formatTime: (ms) ->
                zeroPad = (num, places) ->
                        zero = places - num.toString().length + 1
                        Array(+(zero > 0 && zero)).join("0") + num

                s = Math.floor(ms / 1000)
                MS = ms - s * 1000
                MM = Math.floor(s / 60)
                SS = s - MM * 60
                return "#{zeroPad(MM, 2)}:#{zeroPad(SS, 2)}"


        init: (song, callback) ->
                id = song.sid
                url = song.url
                artist = song.artist
                title = song.title
                album = song.albumtitle
                picture = song.picture
                header_format = "[gb;#fff;#000]"
                window.T.clear()
                window.T.echo "[#{header_format}● ][[gb;#e67e22;#000]#{song.artist} - #{song.title} | #{song.albumtitle}]"


                @t.echo("[Player]",
                {
                        finalize: (div) => @bind(div, callback),
                })

        constructor: (@t) ->
                @t.init_ui = @init.bind(@)
                @t.update_ui = @update.bind(@)
