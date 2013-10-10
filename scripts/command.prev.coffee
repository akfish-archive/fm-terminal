class PrevCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.prev()

(new PrevCommand("prev", "Play previous song.")).register()
