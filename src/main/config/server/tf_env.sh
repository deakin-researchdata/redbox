#!/bin/bash
#
# this script sets the environment for other fascinator scripts
#

export SERVER_URL="${server.url.base}"
export LOCAL_PORT="${server.port}"
export PROJECT_HOME="${app.location.linux}"
export AMQ_PORT="${amq.port}"
export AMQ_STOMP_PORT="${amq.stomp.port}"
export SMTP_HOST="${smtp.host}"
export SMTP_PORT="${smtp.port}"
export SMTP_USERNAME="${smtp.username}"
export SMTP_PASSWORD="${smtp.password}"
export SMTP_SSL="${smtp.ssl}"
export SMTP_TLS="${smtp.tls}"
export SMTP_TESTMODE="${smtp.testmode}"
export SMTP_REDIRECT="${smtp.redirect}"
export ADMIN_EMAIL="${admin.email}"
export NOTIFICATION_SENDER="${notification.sender}"
export MINT_SERVER="${mint.proxy.server}"
export MINT_AMQ="${mint.amq.broker}"
export NON_PROXY_HOSTS="${non.proxy.hosts}"

# set fascinator home directory
if [ -z "$TF_HOME" ]; then
	export TF_HOME="$PROJECT_HOME/home"
fi
export REDBOX_VERSION="${redbox.version}"

# Deakin specific directives
export DRO_SERVER="${dro.server}"
export DRO_USERNAME="${dro.username}"
export DRO_PASSWORD="${dro.password}"
export DRO_NAMESPACE="${dro.namespace}"
export DRO_HANDLER="${dro.handler}"
export DRO_SUBSET="${dro.subset}"
export DOI_KEY="${doi.key}"

# java class path
export CLASSPATH="plugins/*:lib/*"

# Deakin specific settings
DEAKIN_OPTS="-Ddro.server=$DRO_SERVER -Ddro.username=$DRO_USERNAME -Ddro.password=$DRO_PASSWORD -Ddro.namespace=$DRO_NAMESPACE -Ddro.handler=$DRO_HANDLER -Ddro.subset=$DRO_SUBSET -Ddoi.key=$DOI_KEY -Dnotification.sender=$NOTIFICATION_SENDER "

# jvm memory settings
JVM_OPTS="-XX:MaxPermSize=512m -Xmx512m"

# logging directories
export SOLR_LOGS=$TF_HOME/logs/solr
export JETTY_LOGS=$TF_HOME/logs/jetty
export ARCHIVES=$TF_HOME/logs/archives
if [ ! -d $ARCHIVES ]
then
    mkdir -p $ARCHIVES
fi
if [ ! -d $JETTY_LOGS ]
then
    mkdir -p $JETTY_LOGS
fi
if [ ! -d $SOLR_LOGS ]
then
    mkdir -p $SOLR_LOGS
fi

# use http_proxy if defined
if [ -n "$http_proxy" ]; then
	_TMP=${http_proxy#*//}
	PROXY_HOST=${_TMP%:*}
	_TMP=${http_proxy##*:}
	PROXY_PORT=${_TMP%/}
	echo " * Detected HTTP proxy host:'$PROXY_HOST' port:'$PROXY_PORT'"
	PROXY_OPTS="-Dhttp.proxyHost=$PROXY_HOST -Dhttp.proxyPort=$PROXY_PORT -Dhttp.nonProxyHosts=$NON_PROXY_HOSTS"
else
	echo " * No HTTP proxy detected"
fi

# jetty settings
JETTY_OPTS="-Djetty.port=$LOCAL_PORT -Djetty.logs=$JETTY_LOGS -Djetty.home=$PROJECT_HOME/server/jetty"

# solr settings
SOLR_OPTS="-Dsolr.solr.home=$PROJECT_HOME/solr"

# directories
CONFIG_DIRS="-Dfascinator.home=$TF_HOME -Dportal.home=$PROJECT_HOME/portal -Dstorage.home=$PROJECT_HOME/storage"

# mint integration
MINT_OPTS="-Dmint.proxy.server=$MINT_SERVER -Dmint.proxy.url=$MINT_SERVER/mint -Dmint.amq.broker=$MINT_AMQ"

# additional settings
EXTRA_OPTS="-Dserver.url.base=$SERVER_URL -Damq.port=$AMQ_PORT -Damq.stomp.port=$AMQ_STOMP_PORT -Dsmtp.host=$SMTP_HOST -Dsmtp.port=$SMTP_PORT -Dsmtp.username=$SMTP_USERNAME -Dsmtp.password=$SMTP_PASSWORD -Dsmtp.ssl=$SMTP_SSL -Dsmtp.tls=$SMTP_TLS -Dsmtp.testmode=$SMTP_TESTMODE -Dsmtp.redirect=$SMTP_REDIRECT -Dadmin.email=$ADMIN_EMAIL -Dredbox.version=$REDBOX_VERSION"

# Logging fix. Axis 1.4 (for Fedora) needs to know about the SLF4J Implementation
COMMONS_LOGGING="-Dorg.apache.commons.logging.LogFactory=org.apache.commons.logging.impl.SLF4JLogFactory"

# set options for maven to use
export JAVA_OPTS="$COMMONS_LOGGING $JVM_OPTS $JETTY_OPTS $SOLR_OPTS $PROXY_OPTS $CONFIG_DIRS $EXTRA_OPTS $MINT_OPTS $DEAKIN_OPTS"
