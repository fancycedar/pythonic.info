import urllib

import tornado.web
from tornado import httpclient

from vendor.amazon_ses import AmazonSES

from vendor.amazon_ses import EmailMessage

from vendor.BeautifulSoup import BeautifulSoup

from setting import settings


class BaseHandler(tornado.web.RequestHandler):
    def get_current_user(self):
        user_json = self.get_secure_cookie("user")
        if not user_json: return None
        return tornado.escape.json_decode(user_json)

class EmailHandler(AmazonSES):
    def send(self, from_email, user_email, user_msg):
        AmazonSES.__init__(self, settings["AmazonAccessKeyID"], settings["AmazonSecretAccessKey"])
        self.sendEmail(from_email, user_email, user_msg)

    def handle_email(self, response):
        #print response
        #print response.body
        pass

    def _performAction(self, actionName, params=None):
        if not params:
            params = {}
        params['Action'] = actionName
        params = urllib.urlencode(params)

        client = httpclient.AsyncHTTPClient()
        req = httpclient.HTTPRequest("https://email.us-east-1.amazonaws.com/", "POST", self._getHeaders(), params)
        client.fetch(req, self.async_callback(self.handle_email))




