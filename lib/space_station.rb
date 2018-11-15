require 'nio'
require 'redis'
require './core/auth'
require './core/channel_manager'
require './core/task'
require './core/thread_pool'
require './core/parser'
require './core/client'
require './core/engine'


# {
#     account: '123',
#     channel: 'test',
#     data: {
#         message: 123
#     }
# }

::SpaceStation::Engine.new(redis_host: 'localhost').run!

