#!/usr/bin/ruby

# aur-updates.rb
#
# Helper script for Conky to check and display updates to packages installed
# via Arch User Repository.
# 
# Michael Gilchrist (michaelgilch@gmail.com)

require "open-uri"
require "json"

AUR_QUERY_ADDRESS = "https://aur.archlinux.org/rpc.php?v=5&type=multiinfo&arg[]="

class Package
	attr_reader :name, :version

	def initialize(name, version)
		@name = name
		@version = version
	end
end

num_aur_installed = `pacman -Qm | wc -l`

local_package_query_results = `pacman -Qm`
local_packages = local_package_query_results.split("\n").map(&:split).map { |package|
	name, version = package
	Package.new(name, version)
}

dev_packages = ""
local_packages.delete_if do |package|
	if package.name.end_with? "-git","-svn","-cvs","-hg","-bzr","-darcs", "-dev"
		dev_packages += package.name + "\n"
		true
	end
end

num_dev_packages = dev_packages.lines.count

aur_info = AUR_QUERY_ADDRESS + local_packages.map { |package|
	URI.encode_www_form_component(package.name)
}.join("&arg[]=")

json_results = JSON.parse(URI.open(aur_info).read)

available_updates = ""

local_packages.each do |package|
	latest_package = json_results["results"].find { |result| result["Name"] == package.name }
    latest_version = latest_package["Version"]
	 if latest_version != package.version
		 available_updates += "${color2}%-20s ${color3}%-15s ${color2}-> %s\n" % [package.name, package.version, latest_version]
	 end
end

num_non_dev_updates = available_updates.lines.count

if num_non_dev_updates == 0
	available_updates = "${color1}N/A\n"
end

printf "${color0}Arch User Repository  ${hr}\n"
printf "${color1}Installed: ${goto 125}${color2}%s ${alignr}${color1}Updates: ${color2}%s\n\n", num_aur_installed.delete!("\n"), num_non_dev_updates
printf "${color0}Available Updates: ${color1}\n"
printf "${color0}%s", available_updates

printf "\n${color0}Development:\n"
printf "${color1}%s\n", dev_packages

