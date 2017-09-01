#!/bin/bash

sleep $(( $RANDOM % 15 ))
while pgrep -fl "$upload_script"; do sleep $(( $RANDOM % 80 )); done
bash "$upload_script"
