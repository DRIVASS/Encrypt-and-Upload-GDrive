#!/bin/bash

# system.method.set_key = event.download.finished,move_complete,"execute=/home/jesus/scripts/launcher.sh,$d.get_custom1=,$d.get_name="


export label="$1"
export name="$2"


# USER VARIABLES START

# Full path

export full_path="/home/jesus/rtorrent/downloads/completed/$1/$2"

# rTorrent labels

export movie_label="Movie"
export tv_label="TV"
export sport_label="Sport"

# Preferred encoders

export movie_encoders="("HiFi"|"HDChina"|"CtrlHD")"
export tv_encoders="("HiFi"|"HDChina"|"CtrlHD")"

# Folder locations

export script_folder="/home/jesus/scripts"
export queue_folder="/home/jesus/queue"
export encrypt_folder="/home/jesus/encrypt"
export upload_folder="/home/jesus/upload"
export movie_strm_folder="/home/jesus/strm/movies"
export tv_strm_folder="/home/jesus/strm/tv"

# Script filenames

export queue_script="queue.sh"
export upload_script="upload.sh"
export encrypt_script="encrypt.py"
export delete_script="delete.py"
export strm_script="strm.py"

# Salt file & its password

export salt_file="/home/jesus/scripts/salt"
export password="saltpass"

# Google Drive folder ID's

export movie_folder_id="folderid"
export tv_folder_id="folderid"

# Rclone destinations

export movie_destination="remote:/path/to/folder"
export tv_destination="remote:/path/to/folder"
export sport_destination="remote:/path/to/folder"

# Rclone encrypted destinations

export movie_strm_destination="remote:/path/to/folder"
export tv_strm_destination="remote:/path/to/folder"
export list_destination="remote:/path/to/folder"

# USER VARIABLES END


cd "$script_folder"

if [[ "$label" =~ ("$movie_label"|"$tv_label"|"$sport_label") ]]; then bash "$queue_script" & else exit; fi
