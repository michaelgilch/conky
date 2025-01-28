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

puts "${color0}VirtualBox  ${hr}"

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
