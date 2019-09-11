ARG img=

FROM ${img}

ARG apks=

RUN apk update
RUN apk add --no-cache git build-base ncurses ncurses-dev openssh
RUN apk add --no-cache ruby ruby-bundler ruby-dev ruby-rdoc
RUN apk add --no-cache ${apks}

RUN gem install bundler --version "=2.0.2"
RUN bundle config --global silence_root_warning 1

RUN mkdir -p /root/.ssh/
ADD id_rsa /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

COPY . /audit

WORKDIR /audit

RUN bundle install

ENV env=

CMD bundle exec license_audit audit --env=$env