#!/usr/bin/env python
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
import urllib2



class MainHandler(webapp2.RequestHandler):
    def fetch(self, url, data = None):
        try:
            result = urllib2.urlopen(url, data = data)
            return result.read()
        except urllib2.URLError as e:
            return "{\"error\":\"" + e.message + "\"}"
        except urllib2.HTTPError as e:
            return "{\"error\":\"" + e.message + "\"}"
        except:
            return "{\"error\":\"" + "Unknown" + "\"}"

    def data_to_query(self, data):
        return '&'.join(map(lambda (k,v): '='.join([k, str(v)]), data.iteritems()))

    def get_json_p(self, post = False):
        url = self.request.get('url');
        callback = self.request.get('callback');

        data = {}
        for arg in self.request.arguments():
            if arg != 'url' or arg != 'callback':
                data[arg] = self.request.get(arg)

        if not post:
            query = self.data_to_query(data)
            url += "?" + query
            data = None

        self.response.headers['Content-Type'] = "application/json"
        self.response.headers['Access-Control-Allow-Origin'] = "*"
        if callback:
            self.response.write(callback + "(")

        self.response.write(self.fetch(url, data))

        if callback:
            self.response.write(")");

    def get(self):
        self.get_json_p()
    def post(self):
        self.get_json_p(True)


app = webapp2.WSGIApplication([
    ('/', MainHandler)
], debug=True)
