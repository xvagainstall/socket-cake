require 'websocket-eventmachine-client'
require 'json'
require 'net/http' 
class SocketCake
    attr_accessor :task_list, :storage
    def initialize cookie,task_list=[]
        @cookie = cookie
        @task_list = task_list
        @storage = Hash.new
    end
    
    def roll
        EM.run do
            create_sockets @task_list
                ObjectSpace.each_object(BaseSocket).each do |t|
                t.start {|data| @storage[t.class.to_s]=data}
            end
            EM.stop
        end
    end


    private

    def create_sockets (task_list)
        task_list.each do |task|
            klass = Object.const_get(task.name)
            if klass.superclass == BaseSocket
                self.instance_variable_set(:"@#{task.name.downcase}",klass.new(task.task_list, task.url, task.openmessage, @cookie, task.verbose))
            end
        end
    end
end


