#!/usr/bin/ruby
#
# pacman-updates.rb
# Helper script for Conky to check and list pacman updates (native packages only).
#
# Assumptions:
#	  - `pacman-contrib` package is installed, which provides `checkupdates`
#
# Author: Michael Gilchrist (michaelgilch@gmail.com)

# Fetch number of installed packages and pacman cache size
num_installed = `pacman -Qn | wc -l`.strip
cache_size = `du -sh /var/cache/pacman/pkg | cut -f1`.strip

# Fetch the pending updates and count
update_results = `checkupdates`
packages = update_results.lines.map { |line| line.split }
update_count = packages.size 

# Display the Pacman header info
puts "${color0}Pacman  ${hr}"
puts "${color1}Installed: ${goto 125}${color2}#{num_installed} ${alignr}${color1}Updates: ${color2}#{update_count}"
puts "${color1}Cache Size: ${goto 125}${color2}#{cache_size}"
puts ""
puts "${color0}Available Updates: ${color1}"

if update_count > 0
	# Determine the max length of each element of a package to display:
	#   (package name, current version, new version)
	# so the columns displaying the updates can be aligned.
	max_lengths = packages.map { |package_name, curr_vers, _, new_vers| 
		[package_name.length, curr_vers.length, new_vers.length] 
	}.transpose.map(&:max) # get max lengths for aligning columns

  package_display_info = packages.map do |package_name, curr_vers, _, new_vers|
    # Fetch the repository information for the package
    repo = `pacman -Si #{package_name}`[/Repository.*:\s(.*)$/, 1]
    

    # Separate the version numbers into parts
    # - same_part = common version part
    # - curr_diff_part = trailing difference in current version
    # - new_diff_part = trailing difference in new version
    last_delim = 0
    same_part = ""
    curr_diff_part, new_diff_part = curr_vers, new_vers
    # Find the last character before a difference in version numbers
    curr_vers.each_char.with_index do |char, i|
      if curr_vers[i] != new_vers[i]
        if i > 0 
            same_part = curr_vers[0..last_delim-1]
        end
        curr_diff_part = curr_vers[last_delim..]
        new_diff_part = new_vers[last_delim..]
        break
      # elsif ['.','-',':'].include? curr_vers[i]
      else
        last_delim = i
      end
    end
    [repo, package_name, same_part, curr_diff_part, new_diff_part]
  end.sort
  
  package_display_info.each do |repo, package_name, same_part, curr_diff_part, new_diff_part|
    curr_vers_str = "#{same_part}${color2}#{curr_diff_part}" + ' ' * (max_lengths[1] - (same_part.length + curr_diff_part.length))
    new_vers_str = "#{same_part}${color2}#{new_diff_part}"
    
    # Format and print the package update information
    printf "${color1}%-7s ${color2}%-#{max_lengths[0]}s  ${color1}%-#{max_lengths[1]}s  ${color1}=>  ${color1}%-#{max_lengths[2]}s\n", "[#{repo}]", package_name, curr_vers_str, new_vers_str
  end
else
  puts "N/A"
end
