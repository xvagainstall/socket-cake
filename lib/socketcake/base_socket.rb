class SocketCake::BaseSocket

  attr_accessor :url, :open_message, :task_list, :cookie, :completed_tasks, :current_task, :local_storage, :verbose

    def self.get_sequence
        ObjectSpace.each_object(self)
    end

  def initialize task_list, url, open_message, cookie, verbose = false
    self.url = url
    self.open_message = open_message
    self.task_list = task_list
    self.cookie = cookie
    self.completed_tasks = Array.new
    self.local_storage = Hash.new
    self.verbose = verbose
  end

  def start(arg = nil)


    @socket = WebSocket::EventMachine::Client.connect(:uri => self.url,
                                                      headers: {
                                                          'Cookie': self.cookie})


    @socket.onopen do
      puts "#{Time.now} Connected"
      get_task
      
      @socket.send self.open_message
    end

    @socket.onmessage do |msg|
      puts msg if @verbose
      handle(msg)
    end


    @socket.onerror do |error|
      puts error
    end

    @socket.onclose do |code, reason|
      puts "#{Time.now} Disconnected with status code: #{code} and reason: #{reason}"
      yield(local_storage)
    end

    def handle msg
        @message = JSON.parse(msg)
        unless self.current_task[:completed]
                self.send(self.current_task[:name], self.current_task[:args])    
        end
    end

  end


  private
  def task_completed?
    self.current_task[:completed]
  end

  def complete_task
    self.current_task[:completed] = true
    self.completed_tasks << self.current_task
  end

  def next_task
    if task_list.empty?
      @socket.close
    else
      self.current_task = self.task_list.shift
    end
  end

  def get_task
    if self.current_task.nil?
      self.current_task = self.task_list.shift
    end
  end
end