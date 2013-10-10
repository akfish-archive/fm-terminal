# Running on Guest side
class LoginUI 
        wait_for_user = 0
        wait_for_pass = 1
        wait_for_remember = 2

        constructor: () ->
                window.LoginUI = @
                window.Pipe.registerRPC("login_succ", @succ.bind(@))
                window.Pipe.registerRPC("login_fail", @fail.bind(@))
                window.Pipe.registerRPC("login_begin", @begin.bind(@))
                
        showInfo: () ->
                window.T.echo("Login to douban.fm...")
                @echoNeedUser()
                
        exit: () ->
                @pass = ""
                term = window.T
                term.set_mask(false)
                window.TERM.setUser(@user)
                
        echoNeedUser: () ->
                window.T.echo("Username (email address)")
                window.T.set_mask(false)

        echoNeedPass: () ->
                window.T.echo("Password")
                window.T.set_mask(true)

        echoNeedRemember: () ->
                window.T.echo("Remember me? (y/n)")
                window.T.set_mask(false)
                if @remember?
                        window.T.insert(if @remember then "y" else "n")
                
        isValidUser: (user) ->
                return true

        isValidPass: (pass) ->
                return true
                
        succ: (user) ->
                @user = user
                delete @["remember"]
                window.T.pop()
                window.T.resume()
                window.T.echo("Welcome...")
                

        msg_wrong_user = "invalidate_email"
        msg_wrong_pass = "wrong_password"
        
        fail: (user) ->
                @user = user
                err = user.err
                window.T.error("Login failed: #{err}")
                window.T.resume()
                switch err
                        when msg_wrong_user
                                @stage = wait_for_user
                                @echoNeedUser()
                        when msg_wrong_pass
                                @stage = wait_for_pass
                                @echoNeedPass()
                        else
                                window.T.pop()
                
        input: (text, term) ->
                switch @stage
                        when wait_for_user
                                # TODO: validate
                                if @isValidUser(text)
                                        @username = text

                                        # Go pass
                                        @echoNeedPass()
                                        @stage = wait_for_pass
                                else
                                        term.error("Invalid username, try again")
                        when wait_for_pass
                                if @isValidPass(text)
                                        @pass = text

                                        @echoNeedRemember()
                                        @stage = wait_for_remember
                        when wait_for_remember

                                switch text
                                        when "y", "Y"
                                                @remember = true
                                        when "n", "N"
                                                @remember = false
                                        else
                                                @echoNeedRemember()
                                                return
                                # Do login
                                term.echo("Login...")
                                term.pause()

                                window.Pipe.fireRPC "do_login", {username: @username; password: @pass; remember: @remember} 
                                                
                return
                
        begin: () -> 
                @stage = wait_for_user
                
                window.T.push(
                        (input, term) => @input(input, term),
                        {
                                name: "login",
                                prompt: ":",
                                onStart: () => @showInfo(),
                                onExit: () => @exit(),
                                completion: () ->,
                                keydown: (e) -> 
                        })

new LoginUI()
