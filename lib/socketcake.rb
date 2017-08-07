require 'websocket-eventmachine-client'
require 'json'
require 'net/http'
class SocketCake
  attr_accessor :task_list, :storage

  def initialize cookie, task_list=[]
    @cookie = cookie
    @task_list = task_list
    @storage = Hash.new
  end

  def roll
    EM.run do
      create_sockets @task_list
      task_list.each do |task|
        t = self.instance_variable_get(:"@#{task.name.downcase}")
        t.start { |data| @storage[t.class.to_s]=data; EM.stop if task == task_list.last }
      end
    end
  end


  private

  def create_sockets (task_list)

    task_list.each do |task|
      klass = Object.const_get(task.name)
      if klass.superclass == BaseSocket
        self.instance_variable_set(:"@#{task.name.downcase}", klass.new(task.task_list, task.url, task.openmessage, @cookie, task.verbose))
      end
    end
  end
end


