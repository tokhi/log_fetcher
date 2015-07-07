## Log Fetcher 

 This tool requires to have the following gems to run properly
 
```ruby
  require 'open-uri'
  require 'yaml'
  require 'net/http'
  require 'uri'
  require 'iconv' 
  require 'sinatra'
  require 'data_mapper'

  dm-postgres-adapter
```

To configure the tool create a database in postgresql and open the file.yml to change the postgresql settings..

Afterward, run the log_fetcher_tool.rb as below: <br/>
 `ruby log_fetcher_tool.rb`

Then run the log_fetcher.rb:<br/>
 `ruby log_fetcher.rb`
using the above command  the 'thin' web server wll start running. You can also use shotgun to run the log_fetcher.rb if you want (not mandatory!).
Browse localhost via the port number..


