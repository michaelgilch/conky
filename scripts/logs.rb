#!/usr/bin/ruby

# logs.rb
#
# Helper script for Conky to fetch journalctl log errors.
# 
# Michael Gilchrist (michaelgilch@gmail.com)

require 'date'

rawVerboseOutput = `journalctl -p 7 -n 30 -b -o verbose --output-fields=_COMM,_TRANSPORT,SYSLOG_IDENTIFIER,PRIORITY,MESSAGE`.split("\n").to_a
priority = "7"
formattedOutput = ""

rawVerboseOutput.each do |rawLine|
    
    if rawLine[0] != " "
        entryDate = rawLine.split()[1]
        entryTime = rawLine.split()[2]

        formattedDate = Date.parse(entryDate).strftime("%b %d")
        formattedOutput += "${color1}" + formattedDate + " " + entryTime[0..11] + " "

        priority = "7"
        transport = ""
        identifier = ""
        comm = ""
        message = ""
        color = ""
    else
        infoLine = rawLine.split("=")

        if infoLine[0] == "    PRIORITY"
            priority = infoLine[1]
            #formattedOutput += priority + " "
        elsif infoLine[0] == "    _TRANSPORT"
            transport = infoLine[1] + ": " 
            #formattedOutput += "${color0}" + transport  
        elsif infoLine[0] == "    SYSLOG_IDENTIFIER"
            identifier = infoLine[1] + ": "
            formattedOutput += "${color0}" + identifier 
        elsif infoLine[0] == "    _COMM"
            comm = infoLine[1] + ": "
            #formattedOutput += "${color0}" + comm
        elsif infoLine[0] == "    MESSAGE"
            message = rawLine[12..]
            if priority.to_i <= 3                   # emerg, alert, crit, error
                color = "${color4}"                     # red
            elsif priority.to_i == 4                # warning
                color = "${color3}"                     # yellow
            elsif priority.to_i == 5                # notice
                color = "${color0}"                     # blue
            elsif priority.to_i == 6                # info
                color = "${color1}"                     # white
            else                                    # debug
                color = "${color2}"                     # grey
            end
            formattedOutput += color + message + "\n"
        end  
    end
end

printf "${color0}Journal Logs  ${hr}\n"
puts ""
puts formattedOutput

