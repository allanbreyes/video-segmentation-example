CORES      ?= $(shell nproc)
RESOLUTION := 1280x720
TEMPLATE   ?= shotcut.mlt
THUMB_TIME ?= 00:00:27.000
USER       ?= world!
VCODEC     ?= h264_nvenc
export

define STREAMHEADER
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:11
#EXT-X-MEDIA-SEQUENCE:0
endef

.PHONY: all clean dash hls sample stream

all: videos/sample.mp4
# all: dash
all: hls

dash: videos/dash.mpd
hls: videos/hls.m3u8
sample: videos/sample.mp4

export STREAMHEADER
stream: clean
stream:
	@echo 'Rendering on-the-fly, using $(CORES) cores...'
	@echo "$$STREAMHEADER" > ./videos/hls.m3u8
	sed 's/{{name}}/$(USER)/g' $(TEMPLATE) > template.mlt
	melt template.mlt \
		-consumer avformat:videos/hls.m3u8 \
		f=hls \
		preset=fast \
		s=$(RESOLUTION) \
		start_number=0 \
		hls_time=4 \
		hls_list_size=0 \
		real_time=-$(CORES) \
		skip_loop_filter=all \
		skip_frame=bidir

	rm template.mlt

clean:
	@echo 'Cleaning up...'
	-find ./videos -type f -not -name '.keep' -not -name 'sample.mp4' -not -name 'sample.png' -print0 | xargs -0 rm --

videos/sample.mp4:
	@echo 'Downloading sample (Big Buck Bunny)'
	wget -O videos/sample.mp4 http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
	@echo 'Generating thumbnail'
	ffmpeg -i videos/sample.mp4 -ss 00:00:27.000 -vframes 1 videos/sample.png

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
		-c:v $(VCODEC) \
		-f hls \
		-preset:v fast \
		-s $(RESOLUTION) \
		-start_number 0 \
		-hls_time 4 \
		-hls_list_size 0 \
		hls.m3u8
