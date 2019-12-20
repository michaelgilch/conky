#!/usr/bin/ruby

# storage.rb
#
# Helper script for Conky, to display storage information.
#
# Will treat anythong not mounted to /media/ as a permanent device,
# and anything mounted to /media/ as a removable device. 
#
# Michael Gilchrist (michaelgilch@gmail.com)

def make_block_header_lines(block, model)
    puts "${color1}#{model} (#{block})"
    #puts "${color1}Read: ${color2}${diskio_read #{block}} ${goto 175}" \
    #     "${color1}Write: ${color2}${diskio_write #{block}}"
    #puts "${color5}${diskiograph_read #{block} 18,150 0000ff ff0000 -t} ${goto 175}" \
    #     "${color5}${diskiograph_write #{block} 18,150 0000ff ff0000 -t}"
end

def make_partition_line(partition_info)
    _fs, type, size, _used, _avail, percent, mnt = partition_info.split
    "${color2}#{mnt} ${goto 135}${color1}#{type} ${alignr}${color2}#{percent} " \
            "${color1}of${color2} #{size}  ${color5}${fs_bar 10,50 #{mnt}}\n"
end

def display_block_partitions(block_regex)
    partitions = `df -hT | grep #{block_regex} | sort`.split("\n").to_a
    partitions.each { |partition_info| puts make_partition_line(partition_info) }
    puts ''
end

mounted_devices = `df -hT | grep "^/dev/sd*" | sort`.split("\n").to_a
removable_devices = ''
block_devices = []

mounted_devices.each do |device|
    fs, _type, _size, _used, _avail, _percent, mount = device.split

    if mount.start_with?('/media/')
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
