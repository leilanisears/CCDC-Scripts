#!/bin/bash
# Copyright 2022 Daylam Tayari

name="PAM-Check-$(date --iso-8601=seconds).txt"
while read -r lines
do
    echo $(sha512sum $lines) >> $name
done < <(./fd pam_unix.so /)
