require 'nio'
require 'redis'

require './seq/async_sequence'
require './seq/sequence'
require './seq/publish'
require './seq/subscribe'
require './seq/unsubscribe'
require './seq/seq_selector'

require './errors'
require './core/channel_manager'
require './core/thread_pool'
require './core/websocket_parser'
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

