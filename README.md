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
```

### Run
```
require 'space_station'

engine = ::SpaceStation::Engine.new

engine.config_file = "/User/xxx.rb"

engine.run!
```
###