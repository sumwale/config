#!/bin/sh

echo Starting default services
systemctl set-default multi-user.target
systemctl default

sleep 5
echo Remove existing postgres run files. Please wait
mkdir -p /var/run/postgresql
chown -R postgres:postgres /var/run/postgresql
rm -rf /var/run/postgresql/*
systemctl restart postgresql

tail -f -s 10 /dev/null
