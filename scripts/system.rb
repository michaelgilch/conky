#!/usr/bin/ruby
#
# system.rb
#
# Conky helper script for displaying system information.
#
# Michael Gilchrist (michaelgilch@gmail.com)

# General
# -------

def display_header(title)
	puts "\n"
  	puts "${color0}#{title}  ${hr}"
end

def display_blank_line()
  	puts "\n"
end

# Operating System Info
# ---------------------

def display_os()
	puts "${color1}${goto 175}Kernel:  ${color2}${alignr}${kernel}"
	puts "${color1}${goto 175}Uptime:  ${color2}${alignr}${uptime_short}"
end

# CPU Info
# --------

def display_cpu_model()
	cpu_model = `cat /proc/cpuinfo | grep 'model name' | sed -e 's/model name.*: //' | uniq`
	puts "${color1}${alignc}#{cpu_model}"
end

def display_process_info()
	puts "${color1}Processes:     ${color2}${running_processes} ${color1}of${color2} ${processes}"  \
         "${goto 200}${color1}Threads: ${alignr}${color2}${running_threads} ${color1}of${color2} ${threads}"
end

def display_load_and_temp()
    temp = `sensors | grep Package | cut -c 17-23`
    if temp.to_i < 70
        temp_color = "${color2}"
    elsif temp.to_i >= 70 && temp.to_i < 90
        temp_color = "${color3}"
    else
        temp_color = "${color4}"
    end
    puts "${color1}Load: ${color2}${loadavg}${goto 280}${color1}Temp: #{temp_color} ${alignr}#{temp.strip}"
end

def display_cores()
	num_processors = `cat /proc/cpuinfo | grep 'processor' | wc -l`.to_i 
    num_lines = num_processors / 2
    for i in 1..num_lines
        puts "${color1}Core #{i}:  ${color2}${cpu cpu#{i}}%   ${goto 90}${color6}${cpubar cpu#{i} 10,50}" \
             "${goto 200}${color1}Core #{i + num_lines}:  ${color2}${cpu cpu#{i + num_lines}}%   ${goto 250}${color6}${cpubar cpu#{i + num_lines} 10,50}"
    end
end

def display_top_cpu()
    puts '${color1}Process ${goto 200}PID ${goto 280}CPU ${alignr}Time'
    (1..5).to_a.each do |i|
        puts "${color2}${top name #{i}} ${goto 160}${top pid #{i}} ${goto 240}${top cpu #{i}}% ${alignr}${top time #{i}}"
    end
end

# Memory Info
# --------------

def display_mem_usage()
	ram_used = "${color1}Used: ${color2}${mem}${goto 200}${memperc}% ${goto 250}${color5}${membar 13,150}"
	ram_free = "${color1}Free: ${color2}${memfree}${goto 140}${color1} of ${color2}${memmax}"
	buffers = "${goto 200}${color1}Buffers: ${color2}${alignr}${buffers}"
	cached = "${goto 200}${color1}Cached: ${color2}${alignr}${cached}"
	puts ram_used
end

def display_top_mem()
    puts '${color1}Process ${goto 200}PID ${goto 280}Mem ${alignr}Used'
    (1..5).to_a.each do |i|
        puts "${color2}${top_mem name #{i}} ${goto 150} ${top_mem pid #{i}} ${goto 230} ${top_mem mem #{i}}% ${alignr}${top_mem mem_res #{i}}"
    end
end

# Storage Info
# --------------

def make_block_header_lines(block, model)
    puts "${color1}#{model} (#{block})"
    # puts "${color1}Read: ${color2}${diskio_read #{block}} ${goto 175}" \
    #     "${color1}Write: ${color2}${diskio_write #{block}}"
    # puts "${color5}${diskiograph_read #{block} 18,150 0000ff ff0000 -t} ${goto 175}" \
    #     "${color5}${diskiograph_write #{block} 18,150 0000ff ff0000 -t}"
end

def make_partition_line(partition_info)
    _fs, type, size, _used, _avail, percent, mnt = partition_info.split
    mnt_name = mnt.dup
    if mnt_name.start_with?('/run/media/')
        mnt_name.slice! "/run/media/michael/"
    end
    if (mnt_name.length > 14)
        mnt_name = mnt_name[0..14] + '...'
    end
    "${color2}#{mnt_name} ${goto 150}${color1}#{type} ${alignr}${color2}#{percent} " \
            "${color1}of${color2} #{size}  ${color5}${fs_bar 10,50 #{mnt}}\n"
end

def display_block_partitions(block_regex)
    partitions = `df -hT | grep #{block_regex} | sort`.split("\n").to_a
    partitions.each { |partition_info| puts make_partition_line(partition_info) }
    puts ''
end


display_os 
display_header("CPU")
display_cpu_model
display_blank_line
display_process_info
display_load_and_temp
display_blank_line
display_cores
display_blank_line
display_top_cpu
display_header("MEMORY")
display_blank_line
display_mem_usage
display_blank_line
display_top_mem

display_header("STORAGE")
display_blank_line
mounted_devices = `df -hT | grep "^/dev/sd*" | sort`.split("\n").to_a
removable_devices = ''
block_devices = []

mounted_devices.each do |device|
    fs, _type, _size, _used, _avail, _percent, mount = device.split

    if mount.start_with?('/run/media/')
        removable_devices += make_partition_line(device)
    else
        block = fs[5..7]
        unless block_devices.include?(block)
            block_devices.insert(-1, block)
            model = `lsblk -io KNAME,MODEL | grep "^#{block} "`.split('   ').to_a[1].strip
            make_block_header_lines(block, model)
            display_block_partitions("^/dev/#{block}")
        end
    end
end

puts '${color1}Removables:'
puts "${color2}#{removable_devices}"