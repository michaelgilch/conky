#!/usr/bin/ruby
#
# pacman-updates.rb
# Helper script for Conky to check and list pacman updates (explicitly installed native packages only).
#
# Assumptions:
#	  - `pacman-contrib` package is installed, which provides `checkupdates`
#
# Author: Michael Gilchrist (michaelgilch@gmail.com)

# Fetch number of installed packages, packages needing updates, and pacman cache size
begin
  num_installed = `pacman -Qn | wc -l`.strip
  raise "Error fetching installed packages count" if num_installed.empty?

  cache_size = `du -sh /var/cache/pacman/pkg | cut -f1`.strip
  raise "Error fetching cache size" if cache_size.empty?

  # Fetch pending updates for all native packages
  update_results = `checkupdates`
  packages = update_results.lines.map { |line| line.split }
  update_count = packages.size

  # Fetch pending updates only for explicitly installed packages
  explicit_update_results = `checkupdates | grep -F -f <(pacman -Qe | awk '{print $1}')`
  explicit_packages = explicit_update_results.lines.map { |line| line.split }
  explicit_update_count = explicit_packages.size
rescue => e
  puts "Error: #{e.message}"
  exit 1
end

# Display the Pacman header info
puts "${color0}Pacman  ${hr}"
puts "${color1}Installed: ${goto 125}${color2}#{num_installed} ${alignr}${color1}Total Updates: ${color2}#{update_count}"
puts "${color1}Cache Size: ${goto 125}${color2}#{cache_size} ${alignr}${color1}Explicitly Installed: ${color2}#{explicit_update_count}"
puts ""
puts "${color0}Available Updates (Explicit): ${color1}"

if update_count > 0
	# Determine the max length of each element of a package to display:
	#   (package name, current version, new version)
	# so the columns displaying the updates can be aligned.
	max_lengths = explicit_packages.map { |package_name, curr_vers, _, new_vers| 
		[package_name.length, curr_vers.length, new_vers.length] 
	}.transpose.map(&:max) # get max lengths for aligning columns

  # Prepare update information for each package, and sort by package name
  package_display_info = explicit_packages.map do |package_name, curr_vers, _, new_vers|

    # Determine the common prefix length in version strings
    common_length = curr_vers.chars.zip(new_vers.chars).take_while { |a, b| a == b }.size
    same_part = curr_vers[0, common_length]
    curr_diff_part = curr_vers[common_length..]
    new_diff_part = new_vers[common_length..]

    [package_name, same_part, curr_diff_part, new_diff_part]
  end.sort
  
  package_display_info.each do |package_name, same_part, curr_diff_part, new_diff_part|
    curr_vers_str = "#{same_part}${color3}#{curr_diff_part}" + ' ' * (max_lengths[1] - (same_part.length + curr_diff_part.length))
    new_vers_str = "#{same_part}${color3}#{new_diff_part}"
    
    # Format and print the package update information
    printf "${color2}%-#{max_lengths[0]}s  ${color2}%-#{max_lengths[1]}s  ${color1}=>  ${color2}%-#{max_lengths[2]}s\n", package_name, curr_vers_str, new_vers_str
  end
else
  puts "N/A"
end
