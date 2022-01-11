#!/usr/bin/ruby

# logs.rb
#
# Helper script for Conky to fetch journalctl log errors.
# 
# Michael Gilchrist (michaelgilch@gmail.com)

require 'date'

rawVerboseOutput = `journalctl --priority=7 --lines=30 --boot --output=verbose --output-fields=_COMM,_TRANSPORT,SYSLOG_IDENTIFIER,PRIORITY,_PID,MESSAGE`.split("\n").to_a
priority = "7"
formattedOutput = ""

priority = "7"
identifier = ""
comm = ""
message = ""
pid = ""

rawVerboseOutput.each do |rawLine|
    
    if rawLine[0] != " "
        entryDate = rawLine.split()[1]
        entryTime = rawLine.split()[2]

        formattedDate = Date.parse(entryDate).strftime("%d %b")
        formattedOutput += "${color6}" + formattedDate + " "
        formattedOutput += "${color6}" + entryTime[0..11] + " "

        priority = "7"
        identifier = ""
        comm = ""
        message = ""
        pid = ""
    else
        infoLine = rawLine.split("=")

        if infoLine[0] == "    PRIORITY"
            priority = infoLine[1]
        elsif infoLine[0] == "    SYSLOG_IDENTIFIER"
            identifier = infoLine[1] + ": "
        elsif infoLine[0] == "    _COMM"
            comm = infoLine[1]
        elsif infoLine[0] == "    _PID"
            pid = infoLine[1]
        elsif infoLine[0] == "    MESSAGE"
            message = rawLine[12..]
            if priority.to_i <= 3                   # red = emerg, alert, crit, error
                color = "${color4}"
            elsif priority.to_i == 4                # yellow = warning
                color = "${color3}"
            elsif priority.to_i == 5                # grey = notice
                color = "${color1}"
            elsif priority.to_i == 6                # white = info
                color = "${color0}"
            else                                    # blue = debug
                color = "${color2}"
            end

            #formattedOutput += priority + " "
            if identifier == ""
                formattedOutput += "${color0}" + comm + "[" + pid + "]: "
            else
                formattedOutput += "${color0}" + identifier
            end

            # Wrap long messages
            if message.length > 100
                lineNum = 0
                messageArr = message.scan(/.{1,101}/)
                messageArr.each do |msgChunk|
                    lineNum = lineNum + 1
                    if lineNum == 1
                        formattedOutput += color + msgChunk + "\n"
                    else
                        formattedOutput += color + "                    " + msgChunk + "\n"
                    end
                end
            else
                formattedOutput += color + message + "\n"
            end
        end  
    end
end

printf "${color0}Journal Logs  ${hr}\n"
puts ""
puts formattedOutput

