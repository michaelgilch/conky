#!/bin/bash
#
# Launches all Conky scripts

conky -c ~/git/conky/package-info.conf &
conky -c ~/git/conky/system-info.conf &
conky -c ~/git/conky/git-info.conf &
conky -c ~/git/conky/logs.conf &
conky -c ~/git/conky/virtualbox-info.conf &
