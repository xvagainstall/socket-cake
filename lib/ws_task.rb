class WsTask

    attr_accessor :name, :openmessage, :url, :task_list

    def initialize name, message, url, task_list
        self.name = name
        self.openmessage = message
        self.url = url
        self.task_list = task_list
    end
    
    
end