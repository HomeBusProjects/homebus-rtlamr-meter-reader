#!/usr/bin/env ruby

# https://stackoverflow.com/questions/1154846/continuously-read-from-stdout-of-external-process-in-ruby

require 'pty'

require 'open3'

require 'dotenv/load'

cmd = ENV['RTLAMRCMD']
homebus_cmd = 'bundle exec ./homebus-rtlamr-meter-reader.rb --verbose'


while true do
  begin
    PTY.spawn(cmd) { |stdout, stdin, pid|
      begin
        stdout.each do |line|
          puts "got #{line}"

          open('rtl-log.txt', 'a') { |f| f.puts line }

          hstdin, hstdout, hstderr, wait_thr = Open3.popen3('/home/romkey/.rbenv/versions/2.7.4/bin/bundle', 'exec', '/home/romkey/src/homebus-rtlamr-meter-reader/homebus-rtlamr-meter-reader.rb')

          hstdin.puts(line)
          hstdin.close

          exit_code = wait_thr.value

          puts 'homebus out'
          puts hstdout.gets(nil), hstderr.gets(nil)
          puts exit_code
        end
      rescue Errno::EIO
        puts "output ended"
      end
    }
  rescue PTY::ChildExited
    puts "process exited"
  end
end
