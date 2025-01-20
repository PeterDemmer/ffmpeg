# dvd2mp4.sh

Video DVD to .mp4 conversion script using ffmpeg

This script assumes DVD video files called VTS_01_1.VOB et cetera to be present in directory VIDEO_TS.

It supports recombining files lager than 1 GB, which are split up on the DVD.


It performs the following actions:

- Deinterlace e.g.: 
ffmpeg  -i ./VIDEO_TS/VTS_01_1.VOB  -vf yadif  -c:v libx264  -preset slower  -crf 19  -c:a copy  ./VIDEO_TS/VTS_01.dil.mp4

- Detecting shakiness, e.g.:
ffmpeg  -i ./VIDEO_TS/VTS_01.dil.mp4  -vf vidstabdetect=shakiness=10:accuracy=15:result=./VIDEO_TS/VTS_01.trf -f null -

- Stabilising (unshaking) e.g.:
ffmpeg  -i ./VIDEO_TS/VTS_01.dil.mp4  -c:v libx264  -preset slower  -crf 19  -vf vidstabtransform=smoothing=12:zoom=0:input=./VIDEO_TS/VTS_01.trf,unsharp=3:3:1.0:3:3:1.0  -c:a copy  ./VIDEO_TS/VTS_01.stb.mp4

- Side-by-side comparing for checkup, e.g.:
ffmpeg  -i ./VIDEO_TS/VTS_01_1.VOB  -i ./VIDEO_TS/VTS_01.stb.mp4  -filter_complex hstack,format=yuv420p  -c:v libx264  -crf 22  ./VIDEO_TS/VTS_01.sbs.mp4


File e.g. ./VIDEO_TS/VTS_01.stb.mp4 can be used for further processing.

The CRF parameter is set such, that the mp4 files have approximately the same size as the original VOB file(s).

Logs are appended to file log/dvd2mp4.log.

The script can be stopped in a controlled manner using: touch dvd2mp4.stop.

When stopped in a controlled way, the .stop file can be removed, the script can then be restarted and will continue where it left off.

When e.g. a .trf file exists but is older then the .dil.mp4 file it should have been created from, a warning is given.



Note:
I thought a script like this would be rather standard and straightforward, but it took me quite some searching, time and effort to get this right.
Hence this publish.
