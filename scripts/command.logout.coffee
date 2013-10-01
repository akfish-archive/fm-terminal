class LogoutCommand extends window.CommandBase
        execute: () ->
                window.DoubanFM.logout()
                window.T.echo("Logout...")
                window.TERM.setUser(window.DoubanFM.user)

(new LogoutCommand("logout", "Logout from douban.fm")).register()
