#!/usr/bin/ruby

# mem.rb
#
# Helper script for Conky to display network information.
#
# Michael Gilchrist (michaelgilch@gmail.com)

external_ip = `curl icanhazip.com`


puts "${if_up enp5s0}${color1}LAN: ${color2}${addr enp5s0}${alignr}${color1}WAN:  ${color2}#{external_ip}"
puts ''
puts '${color1}Down Speed:  ${color2}${downspeed enp5s0}${goto 175}${color1}Total Down: ${alignr}${color2}${totaldown enp5s0}'
puts '${color1}Up Speed:    ${color2}${upspeed enp5s0}${goto 175}${color1}Total Up: ${alignr}${color2}${totalup enp5s0}'
puts '${endif}'