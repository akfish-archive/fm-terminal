class LoginCommand extends window.CommandBase
        wait_for_user = 0
        wait_for_pass = 1

        showInfo: () ->
                window.T.echo("Login to douban.fm...")
                @echoNeedUser()
                
        echoNeedUser: () ->
                window.T.echo("Username (email address)")
                window.T.set_mask(false)

        echoNeedPass: () ->
                window.T.echo("Password")
                window.T.set_mask(true)
                
        isValidUser: (user) ->
                return true

        isValidPass: (pass) ->
                return true

        exit: () ->
                @pass = ""
                term = window.T
                term.set_mask(false)
                window.TERM.setUser(@user)
                                
        succ: (user) ->
                @user = user
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

                                        # Do login
                                        term.echo("Login...")
                                        term.pause()
                                        # TODO: auto login
                                        window.DoubanFM?.login(@username, @pass, false,
                                                (user) => @succ(user),
                                                (user) => @fail(user))
                return
                
        execute: () ->
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


(new LoginCommand("login", "Login to douban.fm")).register()

