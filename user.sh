#!/bin/bash

source ./common.sh
app_name=user

check_root
app_setup
python_setup
systemd_setup
print_time