class NextCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.next()

(new NextCommand("next", "Play next song.")).register()
