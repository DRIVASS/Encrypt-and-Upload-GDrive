#!/bin/bash

if [ "$label" != "$sport_label" ]; then

     filebot=$(filebot -script fn:amc --output "$queue_folder" --action symlink --conflict skip -non-strict --def ignore="iso|srt|nfo" --def unsorted=y artwork=n excludeList=".excludes" ut_dir="$full_path" ut_kind="multi" ut_title="$name" ut_label="$label" \
     movieFormat="{n} ({y}) [{imdbid}]/{n} ({y}) - {group} {source} {vf} {vc} {ac} {channels}" \
     seriesFormat="{n}/Season {s.pad(2)}/{n} {s00e00} - {group} {source} {vf} {vc} {ac} {channels}" exec="Operation Successful {folder}")
     renamed_videos=$(printf "%s\n" "$filebot" | grep "Execute: Operation Successful" | sed "s/\/Season.*//;s/.*\///" | sort -u)
     if [ -z "$renamed_videos" ]; then exit; fi
     readarray -t videos <<< "$renamed_videos"

fi


if [ "$label" = "$movie_label" ]; then

     for video in "${videos[@]}"; do

         mv "$queue_folder/$video" "$encrypt_folder"
         readarray -t movies <<< "$(find "$encrypt_folder/$video" -mindepth 1 -type l)"

         for movie in "${movies[@]}"; do

             video_renamed=$(echo "$video" | sed "s/\[tt[0-9]*\]//")
             original_name=$(readlink "$movie" | sed "s!.*/!!;s/\.[^.]*$//")
             filesize=$(wc -c < "$movie")

             if grep "$video_renamed" movielist.txt; then

                 match=$(grep -A4 -i "$video_renamed" movielist.txt)
                 current_filesize=$(echo "$match" | grep "fs:" | sed "s/.*fs: //;s/.Bytes//")

                 if [[ "$match" =~ "$original_name" ]]; then

                     rm -rf "$encrypt_folder/$video"
                     break

                 fi

                 if [[ ${match,,} =~ ${movie_encoders,,} ]]; then

                     if [ "$filesize" -gt "$current_filesize" ]; then

                         :

                     else

                         rm -rf "$encrypt_folder/$video"
                         break

                     fi

                 fi

                 if [ "$filesize" -lt "$current_filesize" ]; then

                     rm -rf "$encrypt_folder/$video"
                     break

                 fi

                 sed -i "/vn: $video_renamed/,+5d" movielist.txt
                 file_id=$(echo "$match" | grep "id:" | sed "s/.*id: //")
                 python "$delete_script" "$file_id"

             fi

             movie_file=$(echo "$movie" | sed "s!.*/!!")
             encrypted_file=$(python "$encrypt_script" "$salt_file" "$password" "$encrypt_folder/$video" "$movie_file" "$upload_folder")
             rm -rf "$encrypt_folder/$video"
             rclone copy "$upload_folder/$encrypted_file" "$movie_destination"
             rm "$upload_folder/$encrypted_file"
             python "$strm_script" "$movie_folder_id" "$encrypted_file" "$movie_strm_folder" "$video" "movielist.txt" "$original_name" "$filesize" "$movie_strm_destination" "$list_destination"

         done

     done

     readarray -t extracted_files <<< "$(find "$full_path" -name *.rar -or -name *.zip | sed 's/\.[^.]*$//')"
     rm -rf "${extracted_files[@]}"

elif [ "$label" = "$tv_label" ]; then

     for video in "${videos[@]}"; do

         mv "$queue_folder/$video" "$encrypt_folder"
         readarray -t seasons <<< "$(find "$encrypt_folder/$video" -mindepth 1 -type d -printf '%f\n')"

         for season in "${seasons[@]}"; do

             mkdir -p "$tv_strm_folder/$video/$season"
             readarray -t episodes <<< "$(find "$encrypt_folder/$video/$season" -mindepth 1 -type l)"

             for episode in "${episodes[@]}"; do

                 episode_name=$(echo "$episode" | sed "s!.*/!!;s/\.[^.]*$//;s/\ -[^-]*$//")
                 original_name=$(readlink "$episode" | sed "s!.*/!!;s/\.[^.]*$//")
                 filesize=$(wc -c < "$episode")

                 if grep "$episode_name" tvlist.txt; then

                     match=$(grep -A4 -i "$episode_name" tvlist.txt)
                     current_filesize=$(echo "$match" | grep "fs:" | sed "s/.*fs: //;s/.Bytes//")

                     if [[ "$match" =~ "$original_name" ]]; then

                         rm "$episode"
                         break

                     fi

                     if [[ ${match,,} =~ ${tv_encoders,,} ]]; then

                         if [ "$filesize" -gt "$current_filesize" ]; then

                             :

                         else

                             rm "$episode"
                             break

                         fi

                     fi

                     if [ "$filesize" -lt "$current_filesize" ]; then

                         rm "$episode"
                         break

                     fi

                     sed -i "/vn: $episode_name/,+5d" tvlist.txt
                     file_id=$(echo "$match" | grep "id:" | sed "s/.*id: //")
                     python "$delete_script" "$file_id"

                 fi

                 episode_file=$(echo "$episode" | sed "s!.*/!!")
                 encrypted_file=$(python "$encrypt_script" "$salt_file" "$password" "$encrypt_folder/$video/$season" "$episode_file" "$upload_folder")
                 rm "$episode"
                 rclone copy "$upload_folder/$encrypted_file" "$tv_destination"
                 rm "$upload_folder/$encrypted_file"
                 python "$strm_script" "$tv_folder_id" "$encrypted_file" "$tv_strm_folder/$video/$season" "$episode_name" "tvlist.txt" "$original_name" "$filesize" "$tv_strm_destination/$video/$season" "$list_destination"

             done

             rm -rf "$encrypt_folder/$video/$season"

         done

         rm -rf "$encrypt_folder/$video"

     done

     readarray -t extracted_files <<< "$(find "$full_path" -name *.rar -or -name *.zip | sed 's/\.[^.]*$//')"
     rm -rf "${extracted_files[@]}"

elif [ "$label" = "$sport_label" ]; then

     if [ -f "$full_path" ]; then

         if [[ "$name" = *.rar || "$name" = *.zip ]]; then

             mkdir "$queue_folder/sport"
             unrar e -r -o- "$full_path" "$queue_folder/sport" &> /dev/null
             unzip "$full_path" -d "$queue_folder/sport" &> /dev/null
             unrar e -r -o- "$queue_folder/sport/*.rar" "$queue_folder/sport" &> /dev/null
             unzip "$queue_folder/sport/*.zip" -d "$queue_folder/sport" &> /dev/null
             find "$queue_folder/sport" -type f -not -name "*.zip" -not -name "*.r*" -not -name "*.nfo" -not -name "*.jpg" -not -name "*.png" -not -name "*.srt" -not -name "*.sfv" -exec mv {} "$encrypt_folder" \;
             rm -rf "$queue_folder/sport"
	     readarray -t files <<< "$(find "$encrypt_folder" -type f -printf '%f\n')"

	     for file in "${files[@]}"; do

	         encrypted_file=$(python "$encrypt_script" "$salt_file" "$password" "$encrypt_folder" "$file" "$upload_folder")
	         rm "$encrypt_folder/$file"
                 rclone copy "$upload_folder/$encrypted_file" "$sport_destination"
	         rm "$upload_folder/$encrypted_file"
                 python "$strm_script" "Sport" 2 3 "$file" 5 6 7 8 9

	     done

         else

             ln -s "$full_path" "$encrypt_folder"
             encrypted_file=$(python "$encrypt_script" "$salt_file" "$password" "$encrypt_folder" "$name" "$upload_folder")
	     rm "$encrypt_folder/$name"
             rclone copy "$upload_folder/$encrypted_file" "$sport_destination"
             rm "$upload_folder/$encrypted_file"
             python "$strm_script" "Sport" 2 3 "$name" 5 6 7 8 9

         fi

     else

         mkdir "$queue_folder/sport"
         unrar e -r -o- "$full_path/*.rar" "$queue_folder/sport" &> /dev/null
         unzip "$full_path/*.zip" -d "$queue_folder/sport" &> /dev/null
         find "$queue_folder/sport" -type f -not -name "*.zip" -not -name "*.r*" -not -name "*.nfo" -not -name "*.jpg" -not -name "*.png" -not -name "*.srt" -not -name "*.sfv" -exec mv {} "$encrypt_folder" \;
         find "$full_path" -type f -not -name "*.zip" -not -name "*.r*" -not -name "*.nfo" -not -name "*.jpg" -not -name "*.png" -not -name "*.srt" -not -name "*.sfv" -exec ln -s {} "$encrypt_folder" \;
         rm -rf "$queue_folder/sport"
         readarray -t files <<< "$(find "$encrypt_folder" -type f -printf '%f\n')"

         for file in "${files[@]}"; do

    	     encrypted_file=$(python "$encrypt_script" "$salt_file" "$password" "$encrypt_folder" "$file" "$upload_folder")
             rm "$encrypt_folder/$file"
             rclone copy "$upload_folder/$encrypted_file" "$sport_destination"
             rm "$upload_folder/$encrypted_file"
             python "$strm_script" "Sport" 2 3 "$file" 5 6 7 8 9

    	 done

     fi

fi
