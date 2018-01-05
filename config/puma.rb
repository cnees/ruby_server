workers Integer(ENV['WEB_CONCURRENCY'] || 2)

threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)

# threads min_threads, max_threads
threads threads_count, threads_count

preload_app!

# default is config.ru
rackup      DefaultRackup
port        ENV['PORT']     || 8080
environment ENV['RACK_ENV'] || 'development'
