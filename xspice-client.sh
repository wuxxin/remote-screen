export DISPLAY=:10
cd ~
cp /usr/share/doc/xserver-xspice/spiceqxl.xorg.conf.example .
sudo mv spiceqxl.xorg.conf.example spiceqxl.xorg.conf
sudo Xspice --port 5910 --disable-ticketing --tls-port 0 -noreset $DISPLAY

#!/bin/bash

usage() {
  cat << EOF

    usage: $0 options

    This script starts a new Xspice session

    OPTIONS:
       -h      Show this message
       -u      Username or UID of the user to start the session for (root or sudo only)
       -o      Output only the listening port that the session was started on (and 0 otherwise)

  EOF
}

# Configurables
X_STARTUP_DELAY=10			# The XSpice script needs a little time before it's X server is ready.  If this is set too short, the window manager, etc. will fail to launch properly.
RUNDIR=/var/run/xspice			# Where to store running session info
LOGFILE=~/Xspice/program.log		# Where to store log files ("program" is replaced with the name of the executable being launched)
ERRLOGFILE=~/Xspice/program.err		# Where to store ERROR log files (again, "program" is replaced with the name of the executable being launched)

# Default values BEFORE argument processing
USERNAME=$USER
OUTPUT=1

while getopts "hou:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    u)
      USERNAME=$OPTARG
      ;;
    o)
      OUTPUT=0
      ;;
    ?)
      usage
      exit 1
      ;;
  esac
done

# Create the log directory
LOGDIR=$(dirname $LOGFILE)
if [ ! -d $LOGDIR ]; then
  mkdir $LOGDIR 2>/dev/null >/dev/null
fi

# Create the run directory
if [ $EUID -eq 0 ]; then
  if [ ! -d $RUNDIR ]; then
    mkdir $RUNDIR 2>/dev/null >/dev/null
  fi
  chmod -R 666 $RUNDIR/*
  chmod 777 $RUNDIR
elif [ ! -d $RUNDIR ]; then
  if [ $OUTPUT -gt 0 ]; then
    echo "WARNING: Unable to create "$RUNDIR".  We can continue anyway but if you run this script with sudo it will fix this for you"
  fi
fi

# Find the next available display number
DISPLAY=10
if [ -e $RUNDIR/next_display ]; then
  source $RUNDIR/next_display
fi
while [ $(ps aux |grep Xorg |grep -c :$DISPLAY) -gt 1 ]; do
  DISPLAY=$(($DISPLAY + 1))
done

# Use the display number (+5900) as the TCP port
TCP_PORT=$(($DISPLAY + 5900))
SESSION_START_SCRIPT=/tmp/start-xspice-session-$TCP_PORT.sh

# Write to file the next display number available for use
if [ -d $RUNDIR ]; then
  echo "DISPLAY="$(($DISPLAY + 1)) >$RUNDIR/next_display
  echo "DISPLAY="$DISPLAY >$RUNDIR/session.$USERNAME
  echo "TCP_PORT="$TCP_PORT >>$RUNDIR/session.$USERNAME
fi

# Reformat and export our display variable
export DISPLAY=:$DISPLAY

# Before we start the xspice-xserver instance, let's make sure it's config file is in place
if [ ! -e /etc/X11/spiceqxl.xorg.conf ]; then
  if [ $EUID -eq 0 ]; then
    if [ -e /usr/share/doc/xserver-xspice/spiceqxl.xorg.conf.example ]; then
      cp /usr/share/doc/xserver-xspice/spiceqxl.xorg.conf.example /etc/X11/spiceqxl.xorg.conf
    else
      if [ $OUTPUT -gt 0 ]; then
        echo "FATAL: Unable to locate either 'spiceqxl.xorg.conf.example' or 'spiceqxl.xorg.conf'"
      else
        echo "0"
      fi
      exit 1
    fi
  else
    if [ $OUTPUT -gt 0 ]; then
      echo "FATAL: '/etc/X11/spiceqxl.xorg.conf' does not exist and the current user does not have permission to create it.  Try running this same command as sudo and it will try to fix this for you."
    else
      echo "0"
    fi
    exit 1
  fi
fi

# Create a startup script that we will run as the user
echo "#!/bin/bash" >$SESSION_START_SCRIPT
echo "export DISPLAY="$DISPLAY >>$SESSION_START_SCRIPT
echo "# Start the xspice-xserver instance" >>$SESSION_START_SCRIPT
echo "Xspice --port "$TCP_PORT" --disable-ticketing --tls-port 0 -logfile "$(echo $LOGFILE |sed 's/program/Xorg/g')" -noreset "$DISPLAY" 2>"$(echo $ERRLOGFILE |sed 's/program/Xspice/g')" >"$(echo $LOGFILE |sed 's/program/Xspice/g')" &" >>$SESSION_START_SCRIPT
echo "sleep "$X_STARTUP_DELAY >>$SESSION_START_SCRIPT
echo "" >>$SESSION_START_SCRIPT
echo "# Try to detect if Xorg has started up properly" >>$SESSION_START_SCRIPT
echo "if [ \$(cat "$(echo $LOGFILE |sed 's/program/Xorg/g')" | grep spiceqxl |grep RandR | grep -c enabled) -gt 0 ]; then" >>$SESSION_START_SCRIPT
echo "    # Start the user's session" >>$SESSION_START_SCRIPT
echo "    gnome-session --session=ubuntu 2>"$(echo $ERRLOGFILE |sed 's/program/gnome-session/g')" >"$(echo $LOGFILE |sed 's/program/gnome-session/g')" &" >>$SESSION_START_SCRIPT
echo "    /usr/bin/dbus-launch --exit-with-session gnome-session --session=ubuntu 2>"$(echo $ERRLOGFILE |sed 's/program/dbus-launch/g')" >"$(echo $LOGFILE |sed 's/program/dbus-launch/g')" &" >>$SESSION_START_SCRIPT
echo "    unity 2>"$(echo $ERRLOGFILE |sed 's/program/unity/g')" >"$(echo $LOGFILE |sed 's/program/unity/g')" &" >>$SESSION_START_SCRIPT
echo "fi" >>$SESSION_START_SCRIPT

# Make the startup script executable
chmod +x $SESSION_START_SCRIPT

# Execute the startup script, using su as necessary
if [ "$USER" == "$USERNAME" ]; then
  echo $SESSION_START_SCRIPT
elif [ $EUID -eq 0 ]; then
  echo "su --login -c "$SESSION_START_SCRIPT" "$USERNAME
else
  if [ $OUTPUT -gt 0 ]; then
    echo "FATAL: You can only start a session for another user if you are root ur using sudo"
  else
    echo "0"
  fi
  exit 1
fi

# Final output for the user
if [ $OUTPUT -eq 0 ]; then
  echo $TCP_PORT
else
  echo "A new session has been started and is listening on port "$TCP_PORT
fi
