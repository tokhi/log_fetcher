<h2> Log Fetcher </h2>
<p>
 This tool requires to have the following gems to run properly
</p>
<code>
  require 'open-uri'<br/>
  require 'yaml'<br/>
  require 'net/http'<br/>
  require 'uri'<br/>
  require 'iconv' <br/>
  require 'sinatra'<br/>
  require 'data_mapper'<br/>
<br/>
  dm-postgres-adapter<br/>
  shotgun  (optional)<br/>
 </code>

<p>
 To configure the tool create a database in postgresql and open the file.yml to change the postgresql settings..
</p>
<p>
Afterward, run the log_fetcher_tool.rb as below: <br/>
 <code>ruby log_fetcher_tool.rb</code><br/>

Then run the log_fetcher.rb:<br/>
 <code>ruby log_fetcher.rb</code><br/>
using the above command  the 'thin' web server wll start running. You can also use shotgun to run the log_fetcher.rb if you want (not mandatory!).
Browse localhost via the port number..
</p>

