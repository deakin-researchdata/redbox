from java.lang import String
from java.util import HashMap
from java.io import File
from java.lang import Class
from java.lang import Exception
from org.apache.commons.httpclient.methods import GetMethod
from org.apache.commons.io import IOUtils
from org.json.simple import JSONArray
from com.googlecode.fascinator.common import JsonObject
from com.googlecode.fascinator.common import BasicHttpClient, JsonSimple
from com.googlecode.fascinator.common import FascinatorHome
from com.googlecode.fascinator.common.messaging import MessagingServices
from com.googlecode.fascinator.messaging import EmailNotificationConsumer
from org.apache.commons.mail import HtmlEmail
from org.apache.commons.mail import DefaultAuthenticator;


import sys
#
class TimNotificationData:

    def __init__(self):
        self.messaging = MessagingServices.getInstance()

    def __activate__(self, context):
        self.log = context["log"]
        self.request = context["request"]
        self.sessionState = context["sessionState"]
        self.setting = JsonSimple(context["systemConfig"].getObject("tim.notification"))

        self.sessionState.set("username","admin")
        # read configuration and trigger processing stream sets
        # storing the return object on the map

        self.dataMap = HashMap()
        self.dataMap.put("indexer", context['Services'].getIndexer())

        url = self.setting.getString("","url")
        data = self.__wget(url)
        json = JsonSimple(data)
        if json.getInteger(0,["response","numFound"]) > 0 :
            username = self.setting.getString("",["email","username"])
            password = self.setting.getString("",["email","password"])
            body = self.setting.getString("",["email","body"])
            to = self.setting.getString("",["email","to"])
            if self.setting.getString("",["email","testmode"]) == "true" :
                body = body + "<p>TESTMODE: Was sent to " + to
                to = self.setting.getString("",["email","redirect"])
            email = HtmlEmail()
            email.setAuthenticator(DefaultAuthenticator(username, password))
            email.setHostName(self.setting.getString("localhost",["email","host"]))
            email.setSmtpPort(self.setting.getInteger(25,["email","port"]))
            email.setSSL(self.setting.getBoolean(False,["email","ssl"]))
            email.setTLS(self.setting.getBoolean(False,["email","tls"]))
            email.setFrom(self.setting.getString("",["email","from"]))
            email.setSubject(self.setting.getString("Action Required in TIM",["email","subject"]))
            email.addTo(to)
            email.setHtmlMsg(body)
            email.send()

        
    def __wget(self, url):
        client = BasicHttpClient(url)
        m = GetMethod(url)
        client.executeMethod(m)
        return IOUtils.toString(m.getResponseBodyAsStream(), "UTF-8")
