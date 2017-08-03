require 'minitest/autorun'
require_relative '../lib/socketcake'
require_relative '../lib/ws_task'
require_relative '../lib/base_socket'

require 'pp'

class Ds < BaseSocket
end
class Ws < BaseSocket
end

class SCTest < Minitest::Test

    def test_socket_creation

      open_message= '[{"type":"push","uuid":"J4SA3LNY5AHXMCMMTXA","event_name":"source:set","data_type":"source","timestamp":1499336264302,"data":[{"source":"platform"}]}]'
      open_message2= '[{"type":"push","uuid":"J4SA3LNY5AHXMCMMTXA","event_name":"source:set","data_type":"source","timestamp":1499336264302,"data":[{"source":"platform"}]}]'
      tasks= [{
              name: :get_pair_data,
              completed: false,
              args: {
                pair: 'GBPUSD'
              }
            }]
      tasks2= [{
              name: :open_deal,
              completed: false,
              args: {
                amount: 30,
                duration: 60,
                group: 'real',
                pair: 'GBPUSD',
                direction: 'up'
              }
            }, {
              name: :get_opened_deal,
              completed: false,
              args: {}
            }]
      ds = WsTask.new 'Ds', open_message, 'wss://example.com/ds', tasks
      ws = WsTask.new 'Ws', open_message2, 'wss://example.com/ds', tasks2
      sc = SocketCake.new 'cookie'
      sc.task_list << ds
      sc.task_list << ws
      
      sc.roll

    end


end