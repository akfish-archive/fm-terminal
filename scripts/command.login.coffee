class LoginCommand extends window.CommandBase
        wait_for_user = 0
        wait_for_pass = 1

        showInfo: () ->
                window.T.echo("Login to douban.fm...")
                window.T.echo("Username (email address)")

        isValidUser: (user) ->
                return true

        isValidPass: (pass) ->
                return true
                
        input: (text, term) ->
                switch @stage
                        when wait_for_user
                                # TODO: validate
                                if @isValidUser(text)
                                        @user = text

                                        # Go pass
                                        term.echo("User: #{text}")
                                        term.set_mask(true)
                                        term.echo("Password")
                                        @stage = wait_for_pass
                                else
                                        term.error("Invalid username, try again")
                        when wait_for_pass
                                if @isValidPass(text)
                                        @pass = text

                                        # Do login
                                        term.echo("Login...")

                                        # TODO:
                                        
                                        # done
                                        @pass = ""
                                        term.set_mask(false)
                                        term.pop()
                return
                
        execute: () ->
                @stage = wait_for_user
                
                window.T.push(
                        (input, term) => @input(input, term),
                        {
                                name: "login",
                                prompt: ":",
                                onStart: () => @showInfo(),
                                onExit: () -> console.log("Exit Login"),
                                completion: () ->,
                                keydown: (e) -> console.log(e)
                        })


(new LoginCommand("login", "Login to douban.fm")).register()

