#!/usr/bin/ruby

# pacman-updates.rb
# Helper script for Conky to check and list pacman updates (native packages only).
#
# Assumptions:
#	- pacman database is up-to-date via `pacman -Sy`
#
# Michael Gilchrist (michaelgilch@gmail.com)

update_results = `pacman -Qu`
packages = []
update_count = 0
update_info = ''

packages = update_results.split("\n")

# separate package name and version
packages.map! { |p| p.split }

update_count = packages.count

num_installed = `pacman -Qn | wc -l`
cache_size = `du -h /var/cache/pacman/pkg | cut -f1`

printf "${color0}Pacman  ${hr}\n"
printf "${color1}Installed: ${goto 125}${color2}%s ${alignr}${color1}Updates: ${color2}%s\n", \
       num_installed.delete!("\n"), update_count
printf "${color1}Cache Size: ${goto 125}${color2}%s\n", cache_size
printf "${color0}Available Updates: ${color1}\n"

packages_core = []
packages_extra = []
packages_community = []
packages_multilib = []

if update_count > 0
    packages.each do |name, old_vers, arrow, new_vers|
        info = `pacman -Si #{name}`
        repo = info.match(/Repository.*:\s(.*)$/)[1]
        repo = '[' + repo + ']'
        if repo == '[core]'
            packages_core.push([repo, name, old_vers, new_vers])
        elsif repo == '[extra]'
            packages_extra.push([repo, name, old_vers, new_vers])
        elsif repo == '[community]'
            packages_community.push([repo, name, old_vers, new_vers])
        elsif repo == '[multilib]'
            packages_multilib.push([repo, name, old_vers, new_vers])
        end
    end
    packages_core.each do |repo, name, old_vers, new_vers| 
      printf "${color1}%-11s ${color2}%-20s ${color3}%-15s ${color2}-> %s\n", repo, name, old_vers, new_vers
    end
    packages_extra.each do |repo, name, old_vers, new_vers| 
      printf "${color1}%-11s ${color2}%-20s ${color3}%-15s ${color2}-> %s\n", repo, name, old_vers, new_vers
    end
    packages_community.each do |repo, name, old_vers, new_vers|
      printf "${color1}%-11s ${color2}%-20s ${color3}%-15s ${color2}-> %s\n", repo, name, old_vers, new_vers
    end
    packages_multilib.each do |repo, name, old_vers, new_vers| 
      printf "${color1}%-11s ${color2}%-20s ${color3}%-15s ${color2}-> %s\n", repo, name, old_vers, new_vers
    end
else
  puts "N/A"
end
