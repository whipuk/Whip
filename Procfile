web: bundle exec puma -C config/puma.rb
resque: env TERM_CHILD=1 COUNT=2 QUEUE=* RESQUE_TERM_TIMEOUT=7 bundle exec rake resque:work