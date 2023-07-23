FROM alpine:latest as builder
ARG TARGETPLATFORM
RUN echo "I'm building for $TARGETPLATFORM"

RUN apk add --no-cache gzip && \
    mkdir /clash-config && \
    wget -O /clash-config/Country.mmdb https://raw.githubusercontent.com/Loyalsoldier/geoip/release/Country.mmdb && \
    wget -O /clash-config/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat && \
    wget -O /clash-config/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat && \
    wget -O /clash-config/RuleSet/Unbreak.yaml https://ghproxy.com/https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/Unbreak.yaml && \
    wget -O /clash-config/RuleSet/StreamingMedia/Streaming.yaml https://ghproxy.com/https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/StreamingMedia/Streaming.yaml && \
    wget -O /clash-config/RuleSet/StreamingMedia/StreamingSE.yaml https://ghproxy.com/https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/StreamingMedia/StreamingSE.yaml && \
    wget -O /clash-config/RuleSet/StreamingMedia/StreamingCN.yaml https://ghproxy.com/https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/StreamingMedia/StreamingCN.yaml && \
    wget -O /clash-config/RuleSet/Extra/Game/Steam.yaml https://ghproxy.com/https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/Extra/Game/Steam.yaml && \
    wget -O /clash-config/RuleSet/Global.yaml https://ghproxy.com/https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/Global.yaml && \
    wget -O /clash-config/RuleSet/China.yaml https://ghproxy.com/https://raw.githubusercontent.com/DivineEngine/Profiles/master/Clash/RuleSet/China.yaml && \
    wget -O /clash-config/RuleSet/ChinaIP.yaml https://ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/cncidr.txt


COPY docker/file-name.sh /clash/file-name.sh
WORKDIR /clash
COPY bin/ bin/
RUN FILE_NAME=`sh file-name.sh` && echo $FILE_NAME && \
    FILE_NAME=`ls bin/ | egrep "$FILE_NAME.*"|awk NR==1` && echo $FILE_NAME && \
    mv bin/$FILE_NAME clash.gz && gzip -d clash.gz && echo "$FILE_NAME" > /clash-config/test
FROM alpine:latest
LABEL org.opencontainers.image.source="https://github.com/ahdiua/Clash.Meta"

RUN apk add --no-cache ca-certificates tzdata iptables

VOLUME ["/root/.config/clash/"]

COPY --from=builder /clash-config/ /root/.config/clash/
COPY --from=builder /clash/clash /clash
RUN chmod +x /clash
ENTRYPOINT [ "/clash" ]
