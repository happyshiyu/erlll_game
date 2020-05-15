#!//usr////bin////python
# -*- coding: UTF-8 -*-

import os
import shutil;


proto_src = ".//proto//"
erlang_proto_src = "..//src//proto//"
erlang_include_src = "..//include//"


filename_list = os.listdir("proto")
print os.getcwd()
print filename_list
for filename in filename_list :
	print "escript protoc-erl -strbin " + proto_src + filename
	os.system("escript protoc-erl -strbin " + proto_src + filename)


filename_list = os.listdir("proto")

for filename in filename_list :
	if filename.find(".hrl") > 0 :
		shutil.copyfile(proto_src + filename, erlang_include_src + filename)
		os.remove(proto_src + filename)
	if filename.find(".erl") > 0 :
		shutil.copyfile(proto_src + filename, erlang_proto_src + filename)
		os.remove(proto_src + filename)
