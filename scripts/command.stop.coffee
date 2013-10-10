class StopCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.stop()

(new StopCommand("stop", "Stop playing.")).register()
