class MuteCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.mute()
                
class VolCommand extends window.CommandBase
        execute: (vol) ->
                window.DoubanFM.setVol(vol)
                
(new MuteCommand("mute", "Mute/unmute")).register()
(new VolCommand("vol", "Format: vol <range>. Set volume. Range 0~100. Display current volume if range is not provided.")).register()
