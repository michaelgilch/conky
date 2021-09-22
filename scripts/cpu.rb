#!/usr/bin/ruby

# cpu.rb
#
# Helper script for Conky to display CPU information.
#
# Michael Gilchrist (michaelgilch@gmail.com)

def display_load_and_temp()
    temp = `sensors | grep Package | cut -c 17-23`
    if temp.to_i < 72
        temp_color = "${color2}"
    elsif temp.to_i >= 72 && temp.to_i < 90
        temp_color = "${color3}"
    else
        temp_color = "${color4}"
    end
    puts "${color1}Load:    ${color2}${loadavg}${goto 185}${color1}Temp: #{temp_color} ${alignr}#{temp.strip}"
end

def display_cpu_chart()
    puts "${color5}${cpugraph 18,316 0000ff ff0000 -t}"
end

def display_cores(num_processors)
    num_lines = num_processors / 2
    for i in 1..num_lines
        puts "${color1}Core #{i}:  ${color2}${cpu cpu#{i}}%   ${goto 90}${color6}${cpubar cpu#{i} 10,50}" \
             "${goto 165}${color1}Core #{i + num_lines}:  ${color2}${cpu cpu#{i + num_lines}}%   ${goto 250}${color6}${cpubar cpu#{i + num_lines} 10,50}"
    end
end

def display_threads()
    puts "${color1}Processes:     ${color2}${running_processes} ${color1}of${color2} ${processes}"  \
         "${goto 185}${color1}Threads: ${alignr}${color2}${running_threads} ${color1}of${color2} ${threads}"
end

def display_top_cpu()
    puts ''
    puts '${color1}CPU Usage ${goto 130}   PID ${goto 185}     CPU ${alignr}Time'
    (1..5).to_a.each do |i|
        puts "${color2}${top name #{i}} ${goto 130} ${top pid #{i}} ${goto 185} ${top cpu #{i}}% ${alignr}${top time #{i}}"
    end
end

cpu_model = `cat /proc/cpuinfo | grep 'model name' | sed -e 's/model name.*: //' | uniq`
num_processors = `cat /proc/cpuinfo | grep 'processor' | wc -l`.to_i 

puts "${color1}${alignc}#{cpu_model}"
puts ''

#display_cpu_chart()            <-- SEEMS TO CREATE SEGFAULTS
display_cores(num_processors)
puts ''
display_threads()
display_load_and_temp()
display_top_cpu()

