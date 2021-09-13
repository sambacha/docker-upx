FROM lalyos/scratch-chmx

ADD https://github.com/lalyos/docker-upx/releases/download/v3.94/upx /bin/upx
RUN ["/bin/chmx", "/bin/upx"]

VOLUME /data
WORKDIR /data

ENTRYPOINT ["/bin/upx"]
