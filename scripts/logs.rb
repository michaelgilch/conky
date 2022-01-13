#!/usr/bin/ruby

# logs.rb
#
# Helper script for Conky to fetch journalctl log errors.
# 
# Michael Gilchrist (michaelgilch@gmail.com)

require 'date'

journalctl = 'journalctl --boot'
priorityArg = '--priority=7'
numLines = '--lines=30'
output = '--output=verbose' # Needed for color-coding
fields = '--output-fields=_COMM,SYSLOG_IDENTIFIER,PRIORITY,_PID,MESSAGE'
rawVerboseOutput = `#{journalctl} #{priorityArg} #{numLines} #{output} #{fields}`.split("\n").to_a

# Default Values:
formattedDate = ""
formattedTime = ""
priority = "7" 
identifier = ""
comm = ""
message = ""
pid = ""
entryTime = ""
numMsgLines = 0
msgGroup = ""
msgLines = ""
formattedOutput = ""

# Sample:
# Wed 2022-01-12 19:28:45.330121 EST [s=060abe11b5924a50b4d803469c5814c5;i=2a99;b=500a9e569cfd41ebba0f8ba5db7ef3d7;m=3cbca87e1d;t=5d56bc4e852c9;x=ccf1bcfe94a82e94]
#    _TRANSPORT=kernel
#    PRIORITY=6
#    SYSLOG_IDENTIFIER=kernel
#    MESSAGE=input: SONiX USB Keyboard as /devices/pci0000:00/0000:00:14.0/usb3/3-10/3-10:1.0/0003:0C45:7681.000C/input/input43
#Wed 2022-01-12 19:28:45.386763 EST [s=060abe11b5924a50b4d803469c5814c5;i=2a9a;b=500a9e569cfd41ebba0f8ba5db7ef3d7;m=3cbca95b5f;t=5d56bc4e9300b;x=ad0f5ab873aa43e1]
#    _TRANSPORT=kernel
#    PRIORITY=6
#    SYSLOG_IDENTIFIER=kernel
#    MESSAGE=hid-generic 0003:0C45:7681.000C: input,hidraw3: USB HID v1.11 Keyboard [SONiX USB Keyboard] on usb-0000:00:14.0-10/input0
#Wed 2022-01-12 19:28:45.386958 EST [s=060abe11b5924a50b4d803469c5814c5;i=2a9b;b=500a9e569cfd41ebba0f8ba5db7ef3d7;m=3cbca95c22;t=5d56bc4e930ce;x=39b7875c94ddfe07]
#    _TRANSPORT=kernel
#    PRIORITY=6
#    SYSLOG_IDENTIFIER=kernel
#    MESSAGE=input: SONiX USB Keyboard Consumer Control as /devices/pci0000:00/0000:00:14.0/usb3/3-10/3-10:1.1/0003:0C45:7681.000D/input/input44
rawVerboseOutput.each do |rawLine|
    
    # If the line begins with something other than a space ' ' character, 
    # we know its the start of a log block
    if rawLine[0] != " "
        numMsgLines = numMsgLines + 1

        if numMsgLines > 1
            formattedOutput += "${color6}" + formattedDate + " "
            formattedOutput += "${color6}" + formattedTime + " "   
            formattedOutput += msgGroup 
            formattedOutput += msgLines
        end

        # Reset all values for next message
        formattedDate = ""
        formattedTime = ""
        priority = "7"
        identifier = ""
        comm = ""
        message = ""
        pid = ""

        # Begin gathering new data. 
        # Since this is a starting line of a log block, grab the date and time.
        entryDate = rawLine.split()[1]
        entryTime = rawLine.split()[2]

        formattedDate = Date.parse(entryDate).strftime("%d %b")
        formattedTime = entryTime[0..11]
        
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

            if identifier == ""
                msgGroup = "${color0}" + comm + "[" + pid + "]: "
            else
                msgGroup = "${color0}" + identifier
            end

            # Wrap long messages
            if message.length > 100
                lineNum = 0
                messageArr = message.scan(/.{1,101}/)
                messageArr.each do |msgChunk|
                    lineNum = lineNum + 1
                    if lineNum == 1
                        msgLines = color + msgChunk + "\n"
                    else
                        msgLines += color + "                    " + msgChunk + "\n"
                    end
                end
            else
                msgLines = color + message + "\n"
            end
        end  
    end
end

# add the last entry to the message queue
formattedOutput += "${color6}" + formattedDate + " "
formattedOutput += "${color6}" + entryTime[0..11] + " "   
formattedOutput += msgGroup 
formattedOutput += msgLines

printf "${color0}Journal Logs  ${hr}\n"
puts ""
puts formattedOutput

