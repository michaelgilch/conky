#!/usr/bin/ruby
#
# git.rb
#
# Helper script for Conky, to display git repository information.
#
# Michael Gilchrist (michaelgilch@gmail.com)

require 'open3'

# Root directory containing the subfolders (default is current directory)
root_dir = ARGV[0] || Dir.pwd

changes_detected = false

puts ""

# Fetch and sort the directories
directories = Dir.entries(root_dir)
                  .select { |entry| File.directory?(File.join(root_dir, entry)) && !['.', '..'].include?(entry) }
                  .sort

# Iterate through sorted directories
directories.each do |entry|
  dir_path = File.join(root_dir, entry)
  
  # Skip non-directory entries and entries without a .git folder
  next unless File.directory?(dir_path) && File.directory?(File.join(dir_path, '.git'))
  
  Dir.chdir(dir_path) do
    # Check for untracked files
    untracked_files, _stderr, _status = Open3.capture3('git ls-files --others --exclude-standard')
    if !untracked_files.strip.empty?
      changes_detected = true
      puts "${color1}#{entry}${color2}${alignr}Untracked files detected"
    end

    # Check for unstaged changes
    unstaged_changes, _stderr, _status = Open3.capture3('git diff --stat')
    if !unstaged_changes.strip.empty?
      changes_detected = true
      puts "${color1}#{entry}${color2}${alignr}Unstaged changes detected"
    end

    # Check for staged changes
    staged_changes, _stderr, _status = Open3.capture3('git diff --cached --stat')
    if !staged_changes.strip.empty?
      changes_detected = true
      puts "${color1}#{entry}${color2}${alignr}Staged changes detected"
    end

    # Check for changes not pushed to remote
    Open3.capture3('git fetch --quiet') # Ensure we have the latest info from remote
    local, _stderr, _status = Open3.capture3('git rev-parse @')
    remote, _stderr, _status = Open3.capture3('git rev-parse @{u}')
    base, _stderr, _status = Open3.capture3('git merge-base @ @{u}')

    if remote.strip.empty?
      # puts "  - No remote branch configured."
      changes_detected = true
      puts "${color1}#{entry}${color2}${alignr}No remote branch configured"
    elsif local.strip == remote.strip 
      # puts "  - All changes pushed to remote."
      # no-op
      # puts "${color1}#{entry}${color2}${alignr}Clean"
    elsif local.strip == base.strip
      # puts "  - Changes need to be pulled from remote."
      changes_detected = true
      puts "${color1}#{entry}${color2}${alignr}Pull needed"
    elsif remote.strip == base.strip
      # puts "  - Changes need to be pushed to remote."
      changes_detected = true
      puts "${color1}#{entry}${color2}${alignr}Push needed"
    else
      # puts "  - Divergence detected: both pull and push required."
      changes_detected = true
      puts "${color1}#{entry}${color2}${alignr}Divergence detected"
    end
  end
end

if !changes_detected
  puts "${color1}No changes detected"
end
