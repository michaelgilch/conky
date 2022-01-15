#!/usr/bin/ruby

# logs.rb
#
# Helper script for Conky to fetch journalctl log errors.
# 
# Michael Gilchrist (michaelgilch@gmail.com)

require 'date'

# The following globals hold the results of each journal entry
$formatted_date
$formatted_time
$priority
$syslog_id
$comm
$pid
$message
$source
$formatted_message

# The final output to be displayed
$formatted_output = ""

def set_entry_defaults()
    $formatted_date = ""
    $formatted_time = ""
    $priority = "7" # 7 is used for journal entries that do not have a priority listed
    $syslog_id = ""
    $comm = ""
    $pid = ""
    $message = ""
    $source = ""
    $formatted_message = ""
end

def add_to_formatted_output()
    if $syslog_id == ""
        $source = "${color0}" + $comm
    else
        $source = "${color0}" + $syslog_id
    end

    if $pid != ""
        $source += "[" + $pid + "]: "
    else
        $source += ": "
    end

    $formatted_output += "${color6}" + $formatted_date + " "
    $formatted_output += "${color6}" + $formatted_time + " "   
    #$formatted_output += $priority + " "
    $formatted_output += $source 
    $formatted_output += $formatted_message
end

def format_message()

    if $priority.to_i <= 3                   # red = emerg, alert, crit, error
        color = "${color4}"
    elsif $priority.to_i == 4                # yellow = warning
        color = "${color3}"
    elsif $priority.to_i == 5                # grey = notice
        color = "${color1}"
    elsif $priority.to_i == 6                # white = info
        color = "${color0}"
    else                                    # blue = debug
        color = "${color2}"
    end

    # Wrap long messages
    if $message.length > 100
        lineNum = 0
        messageArr = $message.scan(/.{1,101}/)
        messageArr.each do |msgChunk|
            lineNum = lineNum + 1
            if lineNum == 1
                $formatted_message = color + msgChunk + "\n"
            else
                $formatted_message += color + "                    " + msgChunk + "\n"
            end
        end
    else
        $formatted_message = color + $message + "\n"
    end
end

journalctl = 'journalctl --boot'
priorityArg = '--priority=7'
numLines = '--lines=30'
output = '--output=verbose' # Need PRIORITY for color-coding
fields = '--output-fields=_COMM,SYSLOG_IDENTIFIER,PRIORITY,_PID,MESSAGE'
# journalctl -b -p7 -n10 -overbose --output-fields=_COMM,SYSLOG_IDENTIFIER,PRIORITY,_PID,MESSAGE
rawVerboseOutput = `#{journalctl} #{priorityArg} #{numLines} #{output} #{fields}`.split("\n").to_a

# Default Values:
set_entry_defaults()

# Loop through each line of the raw output (sample entry below), to fetch each individual
# component. Do not add anything to the formatted output until we reach the start of the
# next entry block to make sure we have captured all of the components.
# Sample:
# Fri 2022-01-14 20:46:42.224110 EST [s=060abe11b5924a50b4d803469c5 ...
#   PRIORITY=6
#   SYSLOG_IDENTIFIER=pacman-db-sync.sh
#   MESSAGE=:: Synchronizing package databases...
#   _COMM=pacman
#   _PID=3569275
# Fri 2022-01-14 20:46:43.934000 EST [s=060abe11b5924a50b4d803469c5 ...
#   SYSLOG_IDENTIFIER=audit
#   _PID=1
#   MESSAGE=SERVICE_STOP pid=1 uid=0 auid=4294967295 ses=4294967295 ...
num_msg_lines = 0
rawVerboseOutput.each do |rawLine|
    # If the line begins with something other than a space ' ' character, which should alway
    # be the day of the week part of the date/time stamp, we know its the start of a log block.
    if rawLine[0] != " "
        num_msg_lines = num_msg_lines + 1
        if num_msg_lines > 1
            format_message()
            add_to_formatted_output()
        end

        # Reset all values for next message
        set_entry_defaults()

        # Since this is a starting line of a log block, grab the date and time.
        entryDate = rawLine.split()[1]
        entryTime = rawLine.split()[2]

        $formatted_date = Date.parse(entryDate).strftime("%d %b")
        $formatted_time = entryTime[0..11]
    else
        infoLine = rawLine.split("=")

        if infoLine[0] == "    PRIORITY"
            $priority = infoLine[1]
        elsif infoLine[0] == "    SYSLOG_IDENTIFIER"
            $syslog_id = infoLine[1]
        elsif infoLine[0] == "    _COMM"
            $comm = infoLine[1]
        elsif infoLine[0] == "    _PID"
            $pid = infoLine[1]
        elsif infoLine[0] == "    MESSAGE"
            $message = rawLine[12..]
        end  
    end
end

# Add the last entry to the message queue
format_message()
add_to_formatted_output()

printf "${color0}Journal Logs  ${hr}\n"
puts ""
puts $formatted_output
