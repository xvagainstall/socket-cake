class BaseSocket

  attr_accessor :url, :open_message, :task_list, :cookie, :completed_tasks, :current_task, :storage

    def self.get_sequence
        ObjectSpace.each_object(self)
    end

  def initialize task_list, url, open_message, cookie
    self.url = url
    self.open_message = open_message
    self.task_list = task_list
    self.cookie = cookie
    self.completed_tasks = Array.new
    self.storage = Hash.new
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
      handle(msg)
    end


    @socket.onerror do |error|
      puts error
    end

    @socket.onclose do |code, reason|
      puts "#{Time.now} Disconnected with status code: #{code} and reason: #{reason}"
      yield(self.storage)
    end

    def handle msg
        @message = JSON.parse(msg)
        unless self.current_task[:completed]
            if method_defined? self.current_task[:name]
                self.send(self.current_task[:name], self.current_task[:args])    
            else
                puts 'There is no method you called'
            end
        end
    end

  end


  private
  def build_request(data)
    [{data_type: data[:data_type],
      event_name: data[:event_name],
      timestamp: Time.now.to_i,
      type: 'request',
      uuid: SecureRandom.uuid,
      data: Array.new << data[:data]}]
  end

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