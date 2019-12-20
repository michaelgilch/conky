#!/usr/bin/ruby

# mem.rb
#
# Helper script for Conky to display memory information.
#
# Michael Gilchrist (michaelgilch@gmail.com)

def display_mem_chart()
    puts "${color5}${memgraph 18,316 0000ff ff0000 -t}"
end

def display_top_mem()
    puts ''
    puts '${color1}Mem Usage ${goto 130}   PID ${goto 190}     Mem ${alignr}Used'
    (1..5).to_a.each do |i|
        puts "${color2}${top_mem name #{i}} ${goto 130} ${top_mem pid #{i}} ${goto 190} ${top_mem mem #{i}}% ${alignr}${top_mem mem_res #{i}}"
    end
end

ram_used = "${color1}Used:    ${color2}${memperc}% ${goto 85}${color5}${membar 10,75}"
ram_free = "${color1}Free:   ${color2}${memfree}${color1} of ${color2}${memmax}"
buffers = "${goto 195}${color1}Buffers: ${color2}${alignr}${buffers}"
cached = "${goto 195}${color1}Cached: ${color2}${alignr}${cached}"
puts ''
puts ram_used + buffers
puts ram_free + cached
#display_mem_chart()
display_top_mem()
