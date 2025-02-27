FROM gwzn_bundle_docker

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app

ENV RAILS_ENV production 
RUN bundle config mirror.https://gems.ruby-china.com/ https://mirrors.aliyun.com/rubygems/ && bundle install --jobs=4 --retry=3
CMD bundle exec rake assets:precompile ; bundle exec puma -C config/puma.rb
