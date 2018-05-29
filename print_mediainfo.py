from __future__ import print_function
import glob, os
from pymediainfo import MediaInfo

os.chdir("/media/videodrive/CAMERA_1")
for file in glob.glob("*.mp4"):
    media_info = MediaInfo.parse(file)
    for track in media_info.tracks:
        if track.track_type == 'General':
            print (track.file_name, end=',')
	    print (track.duration, end=',')
        if track.track_type == 'Video':
            print (track.bit_rate, end='\n')

