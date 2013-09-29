class ChannelCommand extends window.CommandBase


(new ChannelCommand("channel", "Show channel list")).register()
#channel_url = "http://www.douban.com/j/app/radio/channels"
#$.ajax(channel_url).done (data) ->
#        console.log(data)
