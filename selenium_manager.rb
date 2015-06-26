require 'webrick'
require 'sys/proctable'
include Sys

# options:
# uses ENV["PORT"] for the port, defaults to 8000

@selenium_pid = nil

def start_server(port)
  server = WEBrick::HTTPServer.new(Port: port)

  server.mount_proc('/start', &method(:start_selenium_req))
  server.mount_proc('/stop', &method(:stop_selenium_req))

  trap 'INT' do server.shutdown end

  server.start
end

def start_selenium_req(req, res)
  start_selenium
  res.body = "started"
end

def stop_selenium_req(req, res)
  stop_selenium
  res.body = "stopped"
end

def start_selenium
  stop_selenium
  @selenium_pid = Process.spawn("run_selenium.bat")
end

def stop_selenium
  if !@selenium_pid.nil?
    to_kill = [@selenium_pid]
    ProcTable.ps do |proc|
      # stop any children processes
      to_kill << proc.pid if to_kill.include?(proc.ppid)
    end

    Process.kill("KILL", *to_kill) rescue nil
    to_kill.each do |pid|
      Process.wait(pid) rescue nil
    end
    sleep 1       # to make sure everything really is stopped (seems necessary even though we do Process.wait)

    @selenium_pid = nil
  end
end

port = ENV.fetch("PORT", 8000).to_i
start_server(port)
