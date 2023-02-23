#!/bin/bash
ln -s $(podman inspect unifi-os -f {{.GraphDriver.Data.MergedDir}})/usr/bin/python3 /usr/bin/python

#if you install pip
ln -s $(podman inspect unifi-os -f {{.GraphDriver.Data.MergedDir}})/usr/local/bin/pip3 /usr/bin/pip
