class BooCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.boo()
                
class LikeCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.like()
                
class UnlikeCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.unlike()

(new BooCommand("boo", "Boo a song. Skip and never play again (need login)")).register()
(new LikeCommand("like", "Like a song. Mark with a red heart. (need login)")).register()
(new UnlikeCommand("unlike", "Unlike a song. Remove red heart (need login)")).register()
