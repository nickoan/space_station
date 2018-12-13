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
file_path 'configure.rb'

set :redis_host, 'localhost'
set :port, 8999
```
