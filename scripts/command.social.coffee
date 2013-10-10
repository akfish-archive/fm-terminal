class BooCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.boo()

(new BooCommand("boo", "Boo a song. Skip and never play again (need login)")).register()
