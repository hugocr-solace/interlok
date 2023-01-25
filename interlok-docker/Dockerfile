FROM adaptris/interlok-base:latest-zulu

ARG java_tool_opts
ENV JAVA_TOOL_OPTIONS=$java_tool_opts

WORKDIR /opt/interlok
COPY . /root/builder

COPY docker-entrypoint-v2.sh /
RUN chmod +x /docker-entrypoint-v2.sh

RUN cd /root/builder && \
    chmod +x /root/builder/gradlew && \
    ./gradlew --no-daemon -PinterlokDistDirectory=/opt/interlok -PbuildEnv=dev build && \
    rm -rf /root/.gradle && \
    rm -rf /root/builder

COPY interlok-rest-health-check-datadog-4.6.jar /opt/interlok/lib

ENV JAVA_TOOL_OPTIONS=""
ENV JAVA_OPTS="-Dsun.net.inetaddr.ttl=30"
ENV INTERLOK_BASE="/opt/interlok"
ENV JVM_ARGS="-XX:MaxRAMPercentage=75.0"
ENV DD_APPSEC_ENABLED=true

EXPOSE 5555 8080

ENTRYPOINT ["/docker-entrypoint-v2.sh"]
CMD [ "bootstrap.properties" ]
