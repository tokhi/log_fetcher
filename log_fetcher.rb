require 'sinatra'
require 'data_mapper'

CONFIG_FILE = "file.yml"
@config = YAML.load_file(CONFIG_FILE)

ADAPTER = @config.fetch('dbconnection')['adapter']
HOST = @config.fetch('dbconnection')['host']
USER_NAME = @config.fetch('dbconnection')['username']
PASSWORD = @config.fetch('dbconnection')['password']
DB = @config.fetch('dbconnection')['database']

DataMapper.setup(:default, "#{ADAPTER}://#{USER_NAME}:#{PASSWORD}@#{HOST}/#{DB}")

class Log
  include DataMapper::Resource
  property :id, Serial
  property :hostname, Text
  property :timestamp, Time
  property :log_id, Text
  property :response, Text
end

begin
  DataMapper.auto_upgrade!
rescue Exception => e
  puts e.message
end

# home page
get '/' do
  @logs = Log.all
  erb :home
end

# shows a specific log
get '/:id' do
  begin
    @log = Log.get params[:id]
    erb :show
  rescue Exception => e
    redirect '/'
  end
end

# search logs based on params
post '/search' do
  if(params[:category] == 'id')
  	@logs = Log.all(:log_id.like => "%#{params[:key]}%")
  end
  
  if(params[:category] =='hostname')
  	@logs = Log.all(:hostname.like => "%#{params[:key]}%") 
  end 
  
  if(params[:category] =='timestamp')
    time = Time.at(params[:key].to_i).to_datetime  
    @logs = Log.all(:timestamp.gte => time) 
  end
  
  if(params[:category] == "24-hrs")
    DAY_IN_SEC = 86400 # 1 day in seconds
    today = Time.now.to_i
    yesterday = Time.at(today-DAY_IN_SEC).to_datetime 
    @logs = Log.all(:timestamp.gte => yesterday)
  end
  erb :home
end
