window.PlayerUI = class PlayerUI
        init: () ->
                @t.echo("PlayerUI...",
                {
                        #finalize: (div) => @bind(div),
                })

        constructor: (@t) ->
                @t.init_ui = @init.bind(@)
