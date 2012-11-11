<h2> Log Fetcher </h2>
<p>
 This tool requires to have the following gems to run properly
</p>
<p>
  require 'open-uri'
  require 'yaml'
  require 'net/http'
  require 'uri'
  require 'iconv' 
  require 'sinatra'
  require 'data_mapper'

  dm-postgres-adapter
  shotgun  (optional)
</p>

<p>
 To configure the tool create a database in postgresql and open the file.yml to change the postgresql settings..
</p>
<p>
Afterward, run the log_fetcher_tool.rb as below: <br/>
 ruby log_fetcher_tool.rb<br/>

Then run the log_fetcher.rb:<br/>
 ruby log_fetcher.rb<br/>
using the above command  the 'thin' web server wll start running. You can also use shotgun instead if you want (not mandatory!).
Browse localhost via the port number..
</p>

