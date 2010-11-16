# -*- coding: utf-8 -*-
require 'rubygems'
framework 'Cocoa'
framework 'WebKit'
require 'socket'
require 'thread'
#require './google.rb'
#require './say.rb'

i = 0
channel = 100

url = ["http://www.youtube.com", "http://www.amazon.co.jp/", "http://www.google.co.jp", "http://keio.jp", "http://twitter.com/"]


application = NSApplication.sharedApplication

# create the window
width  = 800.0
height = 600.0
frame  = [0.0, 0.0, width, height]
mask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
window = NSWindow.alloc.initWithContentRect(frame,
          styleMask:mask,
          backing:NSBackingStoreBuffered,
          defer:false)

# assign a content view instance
content_view = NSView.alloc.initWithFrame(frame)
window.contentView = content_view


web_view_frame = [0.0, 0.0, width, height] # [位置,位置,長さ,長さ] (開始位置は左下)



# web_viewをいっぱい作る
web_views = Array.new
loop do
  web_views[i] = WebView.alloc.initWithFrame(web_view_frame, frameName: "Frame"+ i.to_s, groupName: nil)
  i += 1
  if i == 10
    break
  end
end

i = 0


request = Array.new
while i < 5
  request[i] = NSURLRequest.requestWithURL(NSURL.URLWithString(url[i]))
  web_views[i].mainFrame.loadRequest(request[i])
  content_view.addSubview(web_views[i])
  i += 1
end


# center the window
window.center

# show the window
window.display
window.makeKeyAndOrderFront(nil)
window.orderFrontRegardless


sensors = Array.new(4, 980) # センサーの番号と値を入れる配列


t = Thread.new do
  loop do
    sock = TCPSocket.open("127.0.0.1", 20000) # 127.0.0.1(localhost)の20000番へ接続

    ik = sock.read()
    sensor_and_value = ik.slice(/Sensor.*/)
    sensor = sensor_and_value.slice(/\d+/) # センサー番号
    value = /\d*:\s/.match(sensor_and_value).post_match # センサーの値

    sensors[sensor.to_i] = value.to_i
    
    sum = sensors[0] + sensors[2]
    distance = sensors[2] - sensors[0]

    puts "sensor0 = #{sensors[0]}, sensor2 = #{sensors[2]}, sum = #{sum}, distance = #{distance}"

    pressed = (sensors[1] < 700 || sensors[3] < 700)
    
    if (pressed && 900 < distance)
      unless channel == 0
        channel = 0
        print ("set channel", channel)
        web_views[0].mainFrame.loadRequest(request[0])
        i = 0
        while i < 5
=begin
          if i == channel
            i += 1
            next
          else
=end
            web_views[i].removeFromSuperview
            i += 1
#          end
        end
        content_view.addSubview(web_views[0])
#        web_views[0].setHidden
#        web_views[0].mainFrame.reload
        end
    elsif (pressed && 200 < distance && distance < 900)
      unless channel == 1
        channel = 1
        print ("set channel", channel)
        web_views[1].mainFrame.loadRequest(request[1])
        i = 0
        while i < 5
            web_views[i].removeFromSuperview
            i += 1
        end
        content_view.addSubview(web_views[1])
      end
    elsif (pressed && -200 < distance && distance < 200)
      unless channel == 2
        channel = 2
        print ("set channel", channel)
        web_views[2].mainFrame.loadRequest(request[2])
        i = 0
        while i < 5
            web_views[i].removeFromSuperview
            i += 1
        end
        content_view.addSubview(web_views[2])
      end
    elsif (pressed && -900 < distance && distance < -200)
      unless channel == 3
        channel = 3
        print ("set channel", channel)
        web_views[3].mainFrame.loadRequest(request[3])
        i = 0
        while i < 5
            web_views[i].removeFromSuperview
            i += 1
        end
        content_view.addSubview(web_views[3])
      end
    elsif (pressed && distance < -900)
      unless channel == 4
        channel = 4
        print ("set channel", channel)
        web_views[4].mainFrame.loadRequest(request[4])
        i = 0
        while i < 5
            web_views[i].removeFromSuperview
            i += 1
        end
        content_view.addSubview(web_views[4])
      end
    end
    sleep(0.1)
  end
sock.close # ソケットを閉じる
end


application.run


t.join
