class SocketCake::WsTask
  attr_accessor :name, :openmessage, :url, :task_list, :verbose

  def initialize(name, message, url, task_list, verbose=false)
    self.name = name
    self.openmessage = message
    self.url = url
    self.task_list = task_list
    self.verbose = verbose
  end
end
