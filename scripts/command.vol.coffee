class MuteCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.Mute()
                
class VolCommand extends window.CommandBase
        execute: (vol) ->
                window.DoubanFM.SetVol(vol)
                
(new MuteCommand("mute", "Mute/unmute")).register()
(new VolCommand("vol", "Format: vol <range>. Set volume. Range 0~100.")).register()
