FROM ARG_FROM

MAINTAINER Aliaksandr Pliutau <alexander.plutov@gmail.com>

ADD bin/ARG_ARCH/ARG_BIN /ARG_BIN

USER nobody:nobody
ENTRYPOINT ["/ARG_BIN"]
