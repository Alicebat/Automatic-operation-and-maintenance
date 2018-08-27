#!/usr/bin/env python
# -*- coding:utf-8 -*-
#author:Alicehuang
#description:get local ip adress

import os
import socket,fcntl,struct


def get_ip():
    out = os.popen("ifconfig | grep 'inet' | cut -d: -f 2 | awk '{print $2}' | head -1")
    print (out)

def get_ip2(ifname):
    s =socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(s.fileno(), 0X8915,struct.pack('256s', ifname[:15]))[20:24])


# get_ip()
print get_ip2('enp2s0')
 
#通常使用socket.gethostbyname()方法即可获取本机IP地址，但有时候获取不到(比如没有正确设置主机名称)
# 获取本机计算机名称
hostname = socket.gethostname()
# 获取本机ip
ip = socket.gethostbyname(hostname)
print(ip)
