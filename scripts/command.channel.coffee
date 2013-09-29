
proxy = "https://jsonpwrapper.appspot.com/?callback=?"

channel = "http://www.douban.com/j/app/radio/channels";


class ChannelCommand extends window.CommandBase
        on_data: (data) ->
                window.T.resume()
                x = $("" + data.responseText + "");
 
                jsonp = x[5].innerHTML;
                json = jsonp.substring jsonp.indexOf('(') + 1, jsonp.lastIndexOf(')')

                channels = $.parseJSON(json).channels

                for channel in channels
                        @echo channel.name

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

