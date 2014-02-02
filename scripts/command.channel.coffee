
String.prototype.width =  () ->
        len = @length; 
        width = 0;

        for i, c in @
                if @charCodeAt(i) || @charCodeAt(i) > 126
                        width += 2
                else
                        width++
        return width


class ChannelCommand extends window.CommandBase
        on_data: (data) ->
                window.T.resume()

                channels = data

                max_name_length = 0

                @echo(Array(80).join('-'))

                names = []
                for channel, i in channels
                        name = "#{i}.#{channel.name}"
                        names.push(name)
                        max_name_length = Math.max name.width(), max_name_length

                name_per_line = Math.floor 80 / max_name_length

                table = "<table>"
                line = ""
                space = 2
                for name, i in names
                        if i != 0 and i % name_per_line == 0
                                line += "</tr>"
                                table += line
                                line = "<tr>"
                        str = "[[ub;#2ecc71;#000]#{name}]"
                        formatted = $.terminal.format(str)
                        delta = max_name_length - name.width()
                        line += "<td>#{formatted}</td>"
                table += "</table>"
                @echo table, {raw: true}
                @echo(Array(80).join('-'))
                return
                
        execute: () ->
                if not window.DoubanFM.channels?
                        @echo "Requesting..."
                        window.T.pause()
                        window.DoubanFM.update(
                                (channels) => @on_data(channels),
                                (status, error) => @on_error(status, error)
                        )
                else
                        @on_data(window.DoubanFM.channels)
                return
                        

(new ChannelCommand("channel", "Show channel list")).register()
