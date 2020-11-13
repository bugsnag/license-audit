ARG img=

FROM ${img}

ARG apks=

RUN apk update
RUN apk add --no-cache git build-base ncurses ncurses-dev openssh
RUN apk add --no-cache ruby ruby-bundler ruby-dev ruby-rdoc
RUN apk add --no-cache ${apks}

RUN gem install bundler
RUN bundle config --global silence_root_warning 1

COPY . /audit

WORKDIR /audit

RUN bundle install

ENV app=
ENV build=
ENV clean=
ENV dir=
ENV env=
ENV recent=
ENV wait=

CMD bundle exec license_audit audit --app=${app} \
                                    --build=${build} \
                                    --clean=${clean} \
                                    --dir=${dir} \
                                    --env=${env} \
                                    --recent=${recent} \
                                    --wait=${wait}