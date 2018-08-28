# XMKLiveStream
直播项目(供学习使用)。
直播技术主要包括音视频采集，美颜，编码，解码，推流，拉流，播放，即时通讯聊天，发送礼物，项目中都有涉及。
推流使用rtmp协议,ffmpeg框架。
拉流使用rtmp协议，实测2~3秒延时。
项目中需要使用ijkplayer播放框架，不过这个编译后的库有100多M，太大了无法进行上传，所有需要的筒子请自行导入或者在github上搜索编译好的IJKMediaFramework库直接拖进项目使用。
关于服务器：流媒体服务器nginx+rtmp，IM服务器nodejs+websocket。


