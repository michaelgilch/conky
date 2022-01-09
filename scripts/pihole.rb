#!/usr/bin/ruby
#
# pihole.rb
#
# Helper script for Conky, to display pihole status.
# 
# Requires pi-hole login w/ private key rather than password as well
# as a /etc/sudoers entry to allow running chronometer without password
#   michael ALL=NOPASSWD:/opt/pihole/chronometer.sh
#
# Michael Gilchrist (michaelgilch@gmail.com)

rawHoleStatus = `ssh pihole /opt/pihole/chronometer.sh -e`.split("\n").to_a
displayStatus = ''

# The raw status returned will include some garbled text on the 
# first 4 lines where the PiHole Ascii-Art heading is displayed
# followed by a horizontal line, that we do not want to include.
# 
# Sample:
#   |¯¯¯(¯)_|¯|_  ___|¯|___        Core: API Offline
#   | ¯_/¯|_| ' \/ _ \ / -_)
#   |_| |_| |_||_\___/_\___|
#    ——————————————————————————————————————————————————————————
#     Hostname: pihole             (Raspberry Pi 2, Model B)
#       Uptime: 00:07:04                                                            
#    Task Load: 0.00 0.03 0.01     (Active: 1 of 38 tasks)
#    CPU usage: 1%                 (4x 900 MHz @ 41c)
#    RAM usage: 6%                 (Used: 58 MB of 924 MB)
#    HDD usage: 17%                (Used: 2 GB of 14 GB)
#     LAN addr: 192.168.10.10      (Gateway: 192.168.10.1)
#      Pi-hole: Offline            (Blocking: 101021 sites)
#    Ads Today: 25%                (Total: 18302 of 73316)
#   Local Qrys: 56%                (2 DNS servers)
#      Blocked: www.google-analytics.com                                            
#   Top Advert: scribe.logs.roku.com                                                
#   Top Domain: icanhazip.com                                                       
#   Top Client: MyPC          
rawHoleStatus[4..rawHoleStatus.length].each do |line|
  lineHeader = line[0..11]
  
  # A line might include a 'secondary' set of information in parenthesis like:
  #     Task Load: 0.00 0.03 0.01     (Active: 1 of 38 tasks)
  # which we want to split out and color differently
  lineValue = line[12..].split("(").to_a
  lineValueMain = lineValue[0]
  lineValueSecondary = lineValue[1]

  displayStatus += "${color1}" + lineHeader + "${color2}" + lineValueMain
  if lineValueSecondary != nil
    displayStatus += "${color1}" + "(" + lineValueSecondary
  end
  displayStatus += "\n"
end

puts ''
puts "#{displayStatus}"
