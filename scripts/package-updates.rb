#!/usr/bin/ruby
#
# package-updates.rb
#
# Conky helper script for displaying package updates from both the pacman repositories
# as well as the ArchLinux User Repository (AUR).
#
# Michael Gilchrist (michaelgilch@gmail.com)

require "open-uri"
require "json"

AUR_QUERY_ADDRESS = "https://aur.archlinux.org/rpc.php?v=5&type=multiinfo&arg[]="

def check_for_dependencies()
  if `pacman -Q | grep pacman-contrib` == ""
    puts "Required package: pacman-contrib"
    puts "Exiting"
    exit 1
  end
end

# Helper functions for display formatting
def display_header(title)
  puts "${color0}#{title}  ${hr}"
end

def display_blank_line()
  puts "\n"
end

def display_line(label, value, align_right_label = nil, align_right_value = nil)
  align_right_str = align_right_label ? "${alignr}${color1}#{align_right_label}: ${color2}#{align_right_value}" : ""
  puts "${color1}#{label}: ${goto 125}${color2}#{value} #{align_right_str}"
end

def format_package_update(package_name, curr_vers, new_vers, max_lengths)
  common_length = curr_vers.chars.zip(new_vers.chars).take_while { |a, b| a == b }.size
  same_part = curr_vers[0, common_length]
  curr_diff_part = curr_vers[common_length..]
  new_diff_part = new_vers[common_length..]

  curr_vers_str = "#{same_part}${color3}#{curr_diff_part}" + ' ' * (max_lengths[1] - (same_part.length + curr_diff_part.length))
  new_vers_str = "#{same_part}${color3}#{new_diff_part}"
  
  printf "${color2}%-#{max_lengths[0]}s  ${color2}%-#{max_lengths[1]}s  ${color1}=>  ${color2}%-#{max_lengths[2]}s\n", package_name, curr_vers_str, new_vers_str
end

check_for_dependencies

# Part 1: Pacman Package Updates
begin
  num_installed = `pacman -Qn | wc -l`.strip
  cache_size = `du -sh /var/cache/pacman/pkg | cut -f1`.strip

  # Fetch the pending updates and count
  update_results = `checkupdates`
  packages = update_results.lines.map { |line| line.split }
  update_count = packages.size 

  # Get the list of explicitly installed package names
  explicit_package_names = `pacman -Qe`.lines.map { |line| line.split.first }

  # Filter packages to only those that are explicitly installed
  explicit_packages = packages.select { |package| explicit_package_names.include?(package[0]) }
  explicit_update_count = explicit_packages.size

rescue => e
  puts "Error: #{e.message}"
  exit 1
end

# Part 2: AUR Package Updates
begin
  num_aur_installed = `pacman -Qm | wc -l`.strip
  local_package_query_results = `pacman -Qm`
  local_packages = local_package_query_results.split("\n").map(&:split).map { |package| [package[0], package[1]] }

  dev_packages = local_packages.select { |pkg| pkg[0] =~ /-(git|svn|cvs|hg|bzr|darcs|dev)$/ }
  local_packages -= dev_packages
  num_dev_packages = dev_packages.size

  aur_info = AUR_QUERY_ADDRESS + local_packages.map { |pkg| URI.encode_www_form_component(pkg[0]) }.join("&arg[]=")

  aur_updates = []
  json_results = JSON.parse(URI.open(aur_info).read)

  local_packages.each do |pkg|
    latest_pkg = json_results["results"].find { |result| result["Name"] == pkg[0] }
    if latest_pkg && latest_pkg["Version"] != pkg[1]
      aur_updates << [pkg[0], pkg[1], latest_pkg["Version"]]
    end
  end

rescue OpenURI::HTTPError => e
  puts "${color1}Error fetching AUR updates: #{e.message}${color}"
  exit 1
rescue JSON::ParserError => e
  puts "${color1}Error parsing AUR update data: Invalid JSON response${color}"
  exit 1
rescue => e
  puts "${color1}Unexpected error fetching AUR updates: #{e.message}${color}"
  exit 1
end

# Combine Pacman and AUR updates only for max_lengths calculation
combined_updates = explicit_packages + aur_updates
max_lengths = combined_updates.map { |pkg| [pkg[0].length, pkg[1].length, pkg[2].length] }.transpose.map(&:max)

# Display the Pacman Repo header into
display_header("Pacman")
display_line("Installed", num_installed, "Total Updates", packages.size)
display_line("Cache Size", cache_size, "Explicitly Installed", explicit_packages.size)

# Display Pacman updates
display_blank_line
puts "${color0}Available Updates (Explicit): ${color1}"
if explicit_packages.any?
  explicit_packages.sort.each { |pkg| format_package_update(pkg[0], pkg[1], pkg[3], max_lengths) }
else
  puts "N/A"
end

# Display AUR updates
display_blank_line
display_header("Arch User Repository")
display_line("Installed", num_aur_installed, "Updates", aur_updates.size)
display_blank_line
puts "${color0}Available Updates: ${color1}"
if aur_updates.any?
  aur_updates.sort.each { |pkg| format_package_update(pkg[0], pkg[1], pkg[2], max_lengths) }
else
  puts "N/A"
end

puts "\n${color0}Development:${color1}"
puts dev_packages.map(&:first).join("\n")
