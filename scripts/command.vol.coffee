class MuteCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.mute()
                
class VolCommand extends window.CommandBase
        execute: (vol) ->
                window.DoubanFM.setVol(vol)

class VolUpCommand extends window.CommandBase
        execute: () ->
                vol = window?.DoubanFM?.player?.vol
                if not vol?
                        return
                if vol >= 100
                        window.T?.echo "Max volume"
                        return
                vol = Math.min(100, vol + 10)
                window.DoubanFM.setVol(vol)

class VolDownCommand extends window.CommandBase
        execute: () ->
                vol = window?.DoubanFM?.player?.vol
                if not vol?
                        return
                if vol <= 0
                        window.T?.echo "Min volume"
                        return
                vol = Math.max(0, vol - 10)
                window.DoubanFM.setVol(vol)

                
(new MuteCommand("mute", "Mute/unmute")).register()
(new VolCommand("vol", "Format: vol <range>. Set volume. Range 0~100. Display current volume if range is not provided.")).register()
(new VolUpCommand("up", "Increase volume by 10")).register()
(new VolDownCommand("down", "Decrease volume by 10")).register()
