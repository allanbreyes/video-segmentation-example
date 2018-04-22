Video Segmentation Example
==========================

## How to Run

0. Ensure that [`ffmpeg`][ffmpeg] is installed
1. (Optional) add your own video to `videos/sample.mp4`
2. Start a web server, e.g. `python -m http.server 8000` (Python 3)
3. Run `make`
4. While still loading, visit the web browser to catch the live stream

## (Experimental) On-the-fly Rendering

0. Ensure that [`melt`][mlt] is installed
1. Add `videos/sample.mp4` and start your web server
2. Run `make stream`
3. Visit your web browser

[ffmpeg]: http://ffmpeg.org/download.html
[mlt]: https://www.mltframework.org/docs/install/
