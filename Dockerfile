ARG base=debian:buster-slim

FROM $base as build
RUN apt update -yq
RUN apt install -yq unzip build-essential curl bzip2 dh-autoreconf zlib1g-dev libicu-dev libtommath-dev libncurses-dev
WORKDIR /tmp
RUN curl -sL https://github.com/FirebirdSQL/firebird/releases/download/R3_0_5/Firebird-3.0.5.33220-0.tar.bz2 | tar -jx --strip=1
RUN ./autogen.sh
RUN make -j$(expr `nproc --all` - 1)
RUN make -j$(expr `nproc --all` - 1) dist

FROM $base
LABEL maintainer="eStream Software"
RUN apt update -yq
RUN apt install -yq netbase procps libtommath1 libicu63 libncurses6
WORKDIR /tmp/installer
COPY --from=build /tmp/gen/Firebird-3.0.5.33220-0.amd64 .
RUN sed 's/^installInitdScript$/#installInitdScript/; s/^startFirebird$/#startFirebird/' install.sh | . /dev/stdin -silent
WORKDIR /tmp
RUN rm -fr /tmp/installer
EXPOSE 3050/tcp
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
