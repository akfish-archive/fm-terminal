class PauseCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.pause()

class ResumeCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.resume()

class LoopCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.loops()

(new PauseCommand("pause", "Pause current song.")).register()
(new ResumeCommand("resume", "Resume current song.")).register()
(new LoopCommand("loop", "Loop current song.")).register()
