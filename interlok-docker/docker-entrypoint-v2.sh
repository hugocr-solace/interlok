#!/bin/sh
set -e

JVM_ARGS=${JVM_ARGS:="-Xmx1024m"}
JAVA_OPTS=${JAVA_OPTS:="-Dsun.net.inetaddr.ttl=30"}
INTERLOK_OPTS=${INTERLOK_OPTS:="bootstrap.properties"}
INTERLOK_BASE=${INTERLOK_BASE:="/opt/interlok"}
ASPECT_OPTIONS="-Dorg.aspectj.weaver.loadtime.configuration=META-INF/profiler-aop.xml"
CLASSPATH="/opt/interlok/lib"

cd ${INTERLOK_BASE}
if [ "$(id -u)" = '0' ]; then
  echo "Switching to interlok user"
  chown -R interlok /opt/interlok
  chown --dereference interlok "/proc/$$/fd/1" "/proc/$$/fd/2" || :
  exec gosu interlok java $JVM_ARGS $JAVA_OPTS  -javaagent:lib/aspectjweaver.jar $ASPECT_OPTIONS -jar lib/interlok-boot.jar $INTERLOK_OPTS -Ddd.version=1.0
else
  exec java $JVM_ARGS $JAVA_OPTS -javaagent:lib/aspectjweaver.jar $ASPECT_OPTIONS -jar lib/interlok-boot.jar $INTERLOK_OPTS
fi
