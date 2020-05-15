# erlll_game
一个erlang游戏服务端框架。

# gateway(登录服务器)
使用cowboy实现http服务。

Module | Desc
--- | ---
gateway_server.erl | 启动cowboy并维护登录token | 
gateway_handler.erl | 处理登录的http请求 | 
game_server_manager.erl | 感知并管理游戏服务器 |

# game_server(游戏服务器)
## 1. 网络
1. tcp通信直接采用ranch
2. 简单协议结构：| Length | ProtoId | Binary |, 协议内容部分使用protobuf
3. 以下是部分模块说明
Module | Desc
--- | ---
lib_proto.erl | 负责协议的打包解包 | 
lib_serialize.erl | 序列化与反序列化 | 
 net_listener.erl | 启动ranch进程端口监听 | 
gateway_connector.erl | 连接gateway的模块 |
## 2. 存储 
1. 采用mysql-otp
2. 进程池使用poolboy
3. db.erl 进行数据库相关的操作

## 3. 应用
### player.erl 
```erlang
-record(player, {
    player_id = 0,
    socket,
    transport,
    base_data = #{}, %% 全量保存的key-value数据
    kv_data = #{}, %% 增量保存的key-value数据
    change_k_set = sets:new()
}).
```
1. 每个client接入，都会启动一个与之对应的player，在其中进行数据的接收与返回
2. kv_data中的key-value数据都会以binary的形式回存数据库，并实行增量保存(player_base.erl)
3. base_data中的的key-value数据都会以binary的形式回存数据库，并实行全量保存(player_kv.erl)
4. \#player{}中的数据每5分钟进行一次回存数据库

### base_module.erl
```erlang
-behaviour(base_module).
```
加载到player的数据需要实现的behaviour
1. from_db/1 从db加载数据
2. to_db/1 回存内存数据到db
3. get/3 获取对应模块的数据
4. put/3 存储对应模块的数据
<br>
可参考<font color='red'>player_kv.erl、player_base.erl</font>

### 其他模块
Module | Desc
--- | ---
player_init.erl | 客户端登录成功后，进行player初始化的模块 | 
handler_router.erl | 该模块会根据协议号(ProtoId)选择对应的hander |
client.erl | 模拟客户端 |
make_proto.py | 生成erl对应./make_proto/proto中的协议文件 |
