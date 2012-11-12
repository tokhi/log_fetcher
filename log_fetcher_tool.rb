#!/usr/bin/ruby
require 'open-uri'
require 'yaml'
require 'net/http'
require 'uri'
require 'iconv'

require 'data_mapper'

CONFIG_FILE = "file.yml"
@config = YAML.load_file(CONFIG_FILE)

LOAD_AVG = 'loadavg'
DISC_SPACE = 'discspace'
RESPONSE_TIME = 'responsetime'

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
  property :timestamp, DateTime
  property :log_id, Text
  property :response, Text
end

begin
  DataMapper.auto_upgrade!
rescue Exception => e
  puts "#{e.message}"
end

# ***********PG DATA MAPPER END*************

# loads /proc/loadavf
def loadavg(path, interval)
  while true
    log = Log.new
    log.log_id = LOAD_AVG
    File.open(path, 'r') do |file|
      log.timestamp =  Time.now
      while line = file.gets
	puts line
	log.response = line
      end # while ends
    end # file.open ends
    log.hostname = @config.fetch(RESPONSE_TIME)['responsetime']
    if log.valid?
      log.save
    else
      puts log.errors
    end
    sleep(interval)
   end # while ends
end


# execute shell command defined in yml file
def shellexec(shell_cmd, interval)
  while true
    log = Log.new
    log.log_id = DISC_SPACE 
    log.timestamp =  Time.now
    # execute shell command and store the result in response
    log.response =  %x[#{shell_cmd}]
    log.hostname = @config.fetch(RESPONSE_TIME)['responsetime']
    if log.valid?
      log.save
    else
      puts log.errors
    end
    sleep(interval)
  end # while ends
end


# fetches response from URL
def responsefetcher(url)
  log = Log.new
  log.log_id = RESPONSE_TIME
  log.timestamp =  Time.now
  response=Net::HTTP.get(url)
  # avoid UTF-8 problems
  ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
  log.response = ic.iconv(response)  
  log.hostname = url
  if log.valid?
    log.save
  else
    puts log.errors
  end
end


# Calculate query response time
def responsetimer(url_str,interval)
  url=URI.parse(url_str)
  while true
    log = Log.new
    log.log_id = RESPONSE_TIME
    begin
      start_time = Time.now
      log.timestamp =  start_time
      response =  Net::HTTP.get_response(URI(url_str))
      end_time = Time.now - start_time
      log.response = "#{end_time}"
      log.hostname = url_str
      if log.valid?
      	log.save
      else
      	puts log.errors
      end
    rescue Errno::ECONNREFUSED
     puts "Connection refused"
    end
    # calls the responsfetcher method
    responsefetcher(url)
    sleep(interval)
  end # while ends
end


# loads yml file and fetch..
def load_file
  # commands array
  cmd = Array.new
  @config.each do |key, value| 
    if(key == LOAD_AVG) 
      cmd[0] = @config.fetch(key)['readfile']
      cmd[1] = @config.fetch(key)['interval']
    elsif(key == DISC_SPACE) 
      cmd[2] = @config.fetch(key)['shellexec']
      cmd[3] = @config.fetch(key)['interval']
    elsif(key == RESPONSE_TIME) 
      cmd[4] = @config.fetch(key)['responsetime']
      cmd[5] = @config.fetch(key)['interval']
    elsif(@config.fetch(LOAD_AVG).keys[0] != 'readfile' and @config.fetch(DISC_SPACE).keys[0] != 'shellexec')
      begin
        raise
      rescue
        puts "command not found. Quite!"
      end
   end #if ends
  end #loop ends
  return cmd
end

#************************************************************************************************************************
begin
# calls method load_file..
  cmd = load_file
rescue
end

# assigns array indexes..
file = cmd[0]
file_interval = cmd[1]
cmnd = cmd[2]
cmnd_interval = cmd[3]
url = cmd[4]
url_interval = cmd[5]

# Threads start here..
Thread.abort_on_exception=true 
begin
  t1 = Thread.new{loadavg(file,file_interval)}
  t2 = Thread.new{shellexec(cmnd,cmnd_interval)}
  t3 = Thread.new{responsetimer(url,url_interval)}
  t1.join
  t2.join
  t3.join
rescue Exception => e
  puts "EXCEPTION: #{e.inspect}"
  puts "MESSAGE: #{e.message}"
end
