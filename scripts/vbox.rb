#!/usr/bin/ruby
#
# vbox.rb
#
# Helper script for Conky, to display virtualbox information.
#
# Michael Gilchrist (michaelgilch@gmail.com)

def make_vm_line(vm, isRunning)
  if isRunning
    "${color2}   #{vm}\n"
  else
    "${color1}   #{vm}\n"
  end
end

# def measure()
#     puts "${cpubar cpu1 10,50}${goto 100}${cpubar cpu1 10,50}${goto 200}${cpubar cpu1 10,50}${goto 300}${cpubar cpu1 10,50}"
#     puts "${goto 0}${cpubar cpu1 10,10}${goto 020}${cpubar cpu1 10,10}${goto 40}${cpubar cpu1 10,10}${goto 60}${cpubar cpu1 10,10}${goto 80}${cpubar cpu1 10,10}${goto 100}" \
#          "${cpubar cpu1 10,10}${goto 120}${cpubar cpu1 10,10}${goto 140}${cpubar cpu1 10,10}${goto 160}${cpubar cpu1 10,10}${goto 180}${cpubar cpu1 10,10}${goto 200}" \
#          "${cpubar cpu1 10,10}${goto 220}${cpubar cpu1 10,10}${goto 240}${cpubar cpu1 10,10}${goto 260}${cpubar cpu1 10,10}${goto 280}${cpubar cpu1 10,10}${goto 300}" \
#          "${cpubar cpu1 10,10}${goto 320}${cpubar cpu1 10,10}${goto 340}${cpubar cpu1 10,10}"
#     puts "|${goto 10}.${goto 20}.${goto 30}.${goto 40}.${goto 50}|${goto 60}.${goto 70}.${goto 80}.${goto 90}.${goto 100}" \
#          "|${goto 110}.${goto 120}.${goto 130}.${goto 140}.${goto 150}|${goto 160}.${goto 170}.${goto 180}.${goto 190}.${goto 200}" \
#          "|${goto 210}.${goto 220}.${goto 230}.${goto 240}.${goto 250}|${goto 260}.${goto 270}.${goto 280}.${goto 290}.${goto 300}" \
#          "|${goto 310}.${goto 320}.${goto 330}.${goto 340}.${goto 350}|"
# end

vms = `vboxmanage list --sorted vms`.split("\n").to_a
runningvms = `vboxmanage list --sorted runningvms`.split("\n").to_a

powered_off_vms = ''
powered_on_vms = ''

vms.each do |vm|
  vm_name, vm_uuid = vm.split

  if runningvms.include? vm
    powered_on_vms += make_vm_line(vm_name.delete!('"'), true)
  else
    powered_off_vms += make_vm_line(vm_name.delete!('"'), false)
  end
end

if powered_off_vms == ''
  powered_off_vms += '${color1}   n/a'
end

if powered_on_vms == ''
  powered_on_vms += '${color1}   n/a'
end

puts ''
puts "${color1}Powered On:"
puts "${color2}#{powered_on_vms}"
puts ''
puts '${color1}Powered Off:'
puts "#{powered_off_vms}"
