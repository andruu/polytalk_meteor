require 'polytalk'
require 'yaml'
require 'active_record'

# Setup in sqlite db
dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

# Load schema initially, should probably be programitally... it's a demo!
# ActiveRecord::Base.connection.execute(File.open('schema.sql').read)

# Create our post model
class Post < ActiveRecord::Base
end

Post.destroy_all
1.upto(5) do |i|
  Post.create(title: "Hello I'm post #{i}", body: "I'm the body for post #{i}")
end

# Start your engines
server = Polytalk::Server.new({ port: 9090 })
server.run do |connection, request|
  puts request.to_yaml
  response = server.call(request)
  server.push(connection, response)

  # Close db connection
  ActiveRecord::Base.connection.close
end