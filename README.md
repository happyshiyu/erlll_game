# erlll_game
一个erlang游戏服务端框架。

# gateway(登录服务器)
使用cowboy实现http服务。
1. gateway_server.erl 启动cowboy并维护登录token
2. gateway_handler.erl 处理登录的http请求
3. game_server_manager.erl 感知并管理游戏服务器

# game_server(游戏服务器)
## 1. 网络
1. tcp通信直接采用ranch
2. 简单协议结构：| Length | ProtoId | Binary |, 协议内容部分使用protobuf
3. lib_proto.erl 负责协议的打包解包
4. lib_serialize.erl 序列化与反序列化
5. net_listener.erl 启动ranch进程端口监听 

## 2. 存储层: 
1. 采用mysql+redis, 配套mysql-otp、eredis
2. 进程池使用poolboy
3. db.erl 进行数据库相关的操作
4. cache.erl 进行缓存相关的操作

## 3. 日志层(未实装)

## 4. 应用层
### player.erl 
每个client接入，都会启动一个与之对应的player，在其中进行数据的接收与返回。

### player_init.erl
客户端登录成功后，进行player初始化的模块。

### 未完待续