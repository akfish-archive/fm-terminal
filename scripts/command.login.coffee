class LoginCommand extends window.CommandBase
        execute: () ->
                window.T.login_begin()


(new LoginCommand("login", "Login to douban.fm")).register()

