# Douban FM API Documentation

## Disclaimer

This is not an official documentation. Douban.FM does not provide offical API.
The content in this document is reverse engineered from HTTP traffic of Douban.FM Windows App v0.97.1.
Should only be used for educational and non-commercial purpose and at your own risk.

## API Description

### Overview

As most web service, Douban.FM is JSON based. 

All API access is over HTTP, and accessed from the ```www.douban.com``` domain. All data is sent and received as JSON.

There is no known JSON-P implementation on the server side. 
Thus CORS operation can only be achived by proxying through a JSON-P wrapper.

The features covered by this API contains following:

* User Authentication
* Channel List
* Song List
* Social

### User Authentication

#### Login

##### Request

  ```POST /j/app/login```
##### Parameters

* *email*
      
  Emaill address
      
* *password*
      
  Password. Escaped text.  
      
* *app_name*
      
  App name. For Windows App, the value is ```radio_desktop_win```

* *version*
      
  Version number. For Windows App v0.97.1, the value is ```100```

##### Response

###### Success:

```javascript
{
  "user_id":"2017115",
  "err":"ok",
  "token":"c8f2111141",
  "expire":"1396049442",
  "r":0,
  "user_name":"your user name",
  "email":"your@email.com"
}
```

###### Failed
  
```javascript
{
  "r":1,
  "err":"error description" //e.g. wrong_password
}
```

### Channel List
### Song List
#### Get Songs

##### Request
```GET /j/app/radio/people```

##### Parameters

* *app_name*
      
  App name. For Windows App, the value is ```radio_desktop_win```

* *version*
      
  Version number. For Windows App v0.97.1, the value is ```100```


* *user_id (optional)*
      
  User id from login response


* *expire (optional)*
      
  Expire from login response


* *token (optional)*
      
  Token from login response

* *sid*
      
  Empty

* *channel*
      
  Channel id

* *type*
      
  Value ```n```

##### Response

```javascript
{
  "logout":1, // Only shown if no login information is sent
  "r":0,
  "version_max":100,

  "song":
  [
    // ... Lots of 
    {
      "album":"\/subject\/4732961\/",
      "picture":"http:\/\/img3.douban.com\/mpic\/s4246176.jpg",
      "ssid":"8074",
      "artist":"Ólafur Arnalds",
      "url":"http:\/\/mr4.douban.com\/201309301009\/58419e1d4dfc45d9ff800b559839ff56\/view\/song\/small\/p1639693.mp3",
      "company":"Erased Tapes Records",
      "title":"Gleypa Okkur",
      "rating_avg":4.46059,
      "length":348,
      "subtype":"",
      "public_time":"2010",
      "sid":"1639693",
      "aid":"4732961",
      "sha256":"834329357c6ab0f591d84d14bef8c3e6c9333fdac0661308629785a6101df2ea",
      "kbps":"64",
      "albumtitle":"...And They Have ...",
      "like":0
    },
  
    // ... these are ads
    {
      // ads has diffrent field order and are shorter
      "picture":"http:\/\/img3.douban.com\/view\/dale-online\/dale_ad\/public\/5e5b622ef614274.jpg",
      "albumtitle":"豆瓣FM",
      "adtype":3,
      "monitor_url":"",
      "album":"http:\/\/erebor.douban.com\/redirect\/?ad=60222&uid=2037165&bid=tR%2BWp0yvNAY&unit=dale_fm_audio&crtr=4%3A0&cfg=7afa9e1cc93afb9ffe31d2df4fdf7577ad475e11&ns=1380506962495202000&target=http%3A%2F%2Fwww.douban.com%2Fevent%2F19116031%2F",
      "like":"0",
      "title":"话剧《收信快乐》",
      "url":"http:\/\/mr3.douban.com\/201309301009\/a1a4862dbcef78c6752c3bba658ec39e\/rda\/92f6b87bf5e73f5.mp3",
      "artist":"国家大剧院",
      "subtype":"T",
      "length":15,
      "sid":"da60222_43",
      "aid":"85560222"},

  ]
}
```
### Social
