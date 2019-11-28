#!/bin/bash
nmap -sL $1 | awk '/Nmap scan/{print $NF}'


# Bai 1: Dung bash shell hien thi  out put la dai dia chi IP voi CIDR cho truoc.

# dau tien dung lenh nmap voi option -sL (Scan List) de hien tat ca ip trong CIDR a.b.c.d/e
# tiep theo dung awk de cat chuoi, cu the o day la in ra field cuoi cung ( tuc la field ip address ) cua tat ca
# cac line co string "nmap scan report".
