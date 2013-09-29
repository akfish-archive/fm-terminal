
proxy = "https://jsonpwrapper.appspot.com/?callback=?"

channel = "http://www.douban.com/j/app/radio/channels";


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
                x = $("" + data.responseText + "");
 
                jsonp = x[5].innerHTML;
                json = jsonp.substring jsonp.indexOf('(') + 1, jsonp.lastIndexOf(')')
                parsed = $.parseJSON(json)
                channels = parsed.channels
                if not channels?
                        @echo parsed.error
                max_name_length = 0
                for channel in channels
                        max_name_length = Math.max channel.name.width(), max_name_length

                name_per_line = Math.floor 80 / max_name_length

                line = ""
                space = 2
                for channel, i in channels
                        if i != 0 and i % name_per_line == 0
                                @echo line
                                line = ""
                        name = channel.name
                        delta = max_name_length + space - name.width()
                        line += channel.name + Array(Math.floor(delta / 4)).join("\t")
                @echo line
                return
                
        on_error: () ->
                window.T.resume()
                @echo "Error, try again later"
                return
                
        execute: () ->
                @echo "Requesting..."
                window.T.pause()
                $.ajax({
                        type: 'GET',
                        dateType: 'jsonp',
                        data: {
                                'url': channel
                        },
                        url: proxy,
                        
                        xhrFields: {
                                withCredentials: false
                        },
                        success: (data) =>
                                @on_data data
                                ,
                        error: () ->
                                @on_error
                                return
                })
                return
                        

(new ChannelCommand("channel", "Show channel list")).register()

