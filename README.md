# poorcast
Ultra-low-bandwidth YouTube streaming tool.


### Usage:
```bash
chmod +x poorcast.sh
./poorcast.sh <stream_dir> <rtmp_url> <cpu_core>
```

Script will stream all mp3 files from `<stream_dir>` in random order.
`background.jpg` in the same folder will be used as video background.
You can use different CPU cores to distribute load for different streams.

Example:
```
./poorcast.sh ./mp3_files/ "rtmp://a.rtmp.youtube.com/live2/your-rtmp-key" 1
```


### Setting:
```
BITRATE="128k"
PRESET="ultrafast"
FONT_PATH="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
STATIC_COVER="$DIR/background.jpg"
LOGFILE="$DIR/$(basename "$DIR").log"
```

### Demo
[![Demo Video](https://img.youtube.com/vi/Vapyd8TQ6Jk/0.jpg)](https://www.youtube.com/watch?v=Vapyd8TQ6Jk)
