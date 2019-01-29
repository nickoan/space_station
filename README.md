# space_station
a socket broker

### Transfer Data Struct
```
{
  "channel": ["abcd"],
  "seq": "publish",
  "data":{
    "descirbe": "your own data put here"
  }
}
```

### Configure File

```
set :redis_host, 'localhost'
set :port, 8999

enable :auth 

set :redis_port, 6379
```

### Auth Rule

```
request headers:
account: abcd


#in redis set

key: abcd (account name)

value: {"seq":["subscribe"],"channels":["abcd"]} (format as json)

```

### Run
```
require 'space_station'

engine = ::SpaceStation::Engine.new

engine.config_file = "/User/xxx.rb"

engine.start!
```
###
