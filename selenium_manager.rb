require 'webrick'

# options:
# uses ENV["PORT"] for the port, defaults to 8000

def start_server(port)
  server = WEBrick::HTTPServer.new :Port => 8000

  server.mount_proc('/start', &method(:start_selenium))
  server.mount_proc('/stop', &method(:stop_selenium))

  trap 'INT' do server.shutdown end

  server.start
end

def start_selenium(req, res)
  res.body = "started"
end

def stop_selenium(req, res)
  res.body = "stopped"
end

port = ENV.fetch("PORT", 8000).to_i
start_server(port)
