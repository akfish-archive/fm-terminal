#!/Usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
import urllib
import urllib2
import logging
import base64

logging.getLogger().setLevel(logging.DEBUG)

class MainHandler(webapp2.RequestHandler):
    def fetch(self, url, data = None, debugData = None):
        try:
            result = urllib2.urlopen(url, data = data)
            result_str = result.read()
            if debugData != None:
                debug_str = str(debugData).replace(": u'", ": '")
                return result_str[:-1] + ", " + debug_str[1:]
            return result_str
        except urllib2.URLError as e:
            if debugData != None:
                debugData["except"] = e
                return debugData
            return "{\"error\":\"" + e.message + "\"}"
        except urllib2.HTTPError as e:
            if debugData != None:
                debugData["except"] = e
                return debugData
            return "{\"error\":\"" + e.message + "\"}"

        except BaseException as e:
            if debugData != None:
                debugData["except"] = e
                return debugData
            return "{\"error\":\"" + e.message + "\"}"
        except Exception as e:
            if debugData != None:
                debugData["except"] = e
                return debugData
            return "{\"error\":\"" + e.message + "\"}"

    def data_to_query(self, data):
        return '&'.join(map(lambda (k,v): '='.join([k, str(v)]), data.iteritems()))

    def query_to_data(self, query):
        data = {}
        for pair in query.split("&"):
            split = pair.split("=")
            if len(split) == 2:
                data[split[0]] = split[1]
        return data

    def get_json_p(self, post = False):

        debugData = {}

        b64_url = self.request.get('url');
        callback = self.request.get('callback');
        payload = self.request.get('payload');

        debugData["b64_url"] = b64_url
        debugData["cb"] = callback
        debugData["b64_payload"] = payload

        url = base64.b64decode(b64_url)
        query = base64.b64decode(payload)
        data = self.query_to_data(query)

        debugData["url"] = url
        debugData["query"] = query
        debugData["query_to_data"] = data


        debugData["mode"] = "POST"
        if not post:
            debugData["mode"] = "GET"
            url += "?" + urllib.urlencode(data)
            debugData["url"] = url
            data = None


        self.response.headers['Content-Type'] = "application/javascript"
        self.response.headers['Access-Control-Allow-Origin'] = "*"

        logging.warn("POST:", post)
        logging.warn(post)
        logging.warn("URL:")
        logging.warn(url)
        logging.warn("Data:")
        logging.warn(data)

        if callback:
            self.response.write(callback + "(")
        self.response.write(self.fetch(url, data, debugData))

        if callback:
            self.response.write(");");

    def get(self):
        self.get_json_p()
    def post(self):
        self.get_json_p(True)


app = webapp2.WSGIApplication([
    ('/', MainHandler)
], debug=True)
