RESOLUTION := 1280x720
.PHONY: all clean dash hls

all: videos/sample.mp4
# all: dash
all: hls

dash: videos/dash.mpd
hls: videos/hls.m3u8

clean:
	@echo 'Cleaning up...'
	-find ./videos -type f -not -name '.keep' -not -name 'sample.mp4' -print0 | xargs -0 rm --

videos/sample.mp4:
	@echo 'Downloading sample (Big Buck Bunny)'
	wget -O videos/sample.mp4 http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4

videos/dash.mpd:
	@echo 'Building MPEG-DASH...'
	cd videos && ffmpeg -i sample.mp4 \
		-s $(RESOLUTION) \
		-f dash \
		-min_seg_duration 5000 \
		-init_seg_name "dash-init-\$$RepresentationID\$$.m4s" \
		-media_seg_name "dash-chunk-\$$RepresentationID\$$-\$$Number%05d\$$.m4s" \
		dash.mpd

videos/hls.m3u8:
	@echo 'Building HLS...'
	cd videos && ffmpeg -i sample.mp4 \
		-preset:v ultrafast \
		-s $(RESOLUTION) \
		-start_number 0 \
		-hls_time 5 \
		-hls_list_size 0 \
		-f hls \
		hls.m3u8
