# erlll_game
一个erlang游戏服务端框架。

## 1. 网络
1. tcp通信直接采用ranch
2. 简单协议结构：| Length | ProtoId | Binary |, 协议内容部分使用protobuf
3. lib_proto.erl:负责协议的打包解包
4. srv_role.erl: 对应玩家进程

## 2. 存储层: 
1. 采用mysql+redis, 配套mysql-otp、eredis
2. 进程池使用poolboy

## 3. 日志层(未实装)

## 4. 应用层(未实装)