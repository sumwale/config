#!/bin/bash -e

SCRIPT=$(basename "$0")
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)

source "$SCRIPT_DIR/entrypoint-common.sh"

config_list=
config_dir=
app_list=
pkgmgr_conf="$SCRIPT_DIR/pkgmgr.conf"
startup_list=

# first clear the status_file
echo -n > $status_file

function show_usage() {
  echo
  echo "Usage: $SCRIPT [-c CONFIG_LIST] [-d CONFIG_DIR] [-a APP_LIST]"
  echo "       [-s STARTUP_LIST] [-h] BOX_NAME"
  echo
  echo "Arguments:"
  echo "  BOX_NAME         name of the linux box container being created"
  echo
  echo "Options:"
  echo "  -c CONFIG_LIST   file having list of configuration files to be setup in user's HOME"
  echo "  -d CONFIG_DIR    target directory having configuration files"
  echo "  -a APP_LIST      file having list of applications to be installed"
  echo "                   (each line should start with any additional package manager flags)"
  echo "  -s STARTUP_LIST  file containing list of startup applications for the container"
  echo "  -h               show this help message and exit"
}

# link the configuration files in HOME to the target directory having the required files
function link_config_files() {
  # line is of the form <src> -> <dest>; pattern below matches this while trimming spaces
  echo_color "$fg_orange" "Linking configuration files from $config_dir to user's home" >> $status_file
  pattern='(.*[^[:space:]]+)[[:space:]]*->[[:space:]]*(.*)'
  while read -r config; do
    if [[ "$config" =~ $pattern ]]; then
      home_file="${BASH_REMATCH[1]}"
      dest_file="$config_dir/${BASH_REMATCH[2]}"
      # only replace the file if it is already a link (assuming the link target may
      #   have changed in the config_list file)
      if [ -L "$home_file" ]; then
        rm -f "$home_file"
      fi
      if [ ! -e "$home_file" ]; then
        ln -s "$dest_file" "$home_file"
      fi
    else
      echo_color "$fg_red" "Skipping config line having unknown format: $config" >> $status_file
    fi
  done < "$config_list"
}

# install applications listed in the given file with 
function install_apps() {
  # source PKGMGR_* variables from the configuration file created by 'lbox-create'
  source "$pkgmgr_conf"
  if [ -z "$PKGMGR_INSTALL" -o \
       -z "$PKGMGR_REMOVE" -o -z "$PKGMGR_UPDATE_ALL" ]; then
    echo_color "$fg_red" "$pkgmgr_conf should define all of PKGMGR_INSTALL, PKGMGR_REMOVE and PKGMGR_UPDATE_ALL" >> $status_file
    exit 1
  fi
  # install packages line by line
  while read -r pkg_line; do
    echo_color "$fg_orange" "Installing: ${pkg_line:0:40} ..." >> $status_file
    $PKGMGR_INSTALL $pkg_line
  done < "$app_list"
}

# invoke the startup apps as listed in the container configuration file
function invoke_startup_apps() {
  log_dir="$HOME/.local/share/linuxbox/logs"
  log_no=1
  # start apps in the order listed in the file
  while read -r app_line; do
    mkdir -p "$log_dir"
    echo_color "$fg_orange" "Starting: ${app_line:0:40} ..." >> $status_file
    nohup $app_line >> "$log_dir/app-${log_no}_out.log" 2>> "$log_dir/app-${log_no}_err.log"   &
    sleep 1
  done < "$startup_list"
}


while getopts "c:d:a:s:h" opt; do
  case "$opt" in
    c)
      config_list="$OPTARG"
      ;;
    d)
      config_dir="$OPTARG"
      ;;
    a)
      app_list="$OPTARG"
      # assume package manager configuration to be in pkgmgr.conf in same dir as this script
      if [ ! -r "$pkgmgr_conf" ]; then
        echo "Cannot find $pkgmgr_conf to apply the given APP_LIST"
        exit 1
      fi
      ;;
    s)
      startup_list="$OPTARG"
      ;;
    h)
      show_usage
      exit 0
      ;;
    ?)
      show_usage
      exit 1
      ;;
  esac
done

if [ -n "$config_list" -a -z "$config_dir" ]; then
  echo "$0: missing '-d CONFIG_DIR' option for given CONFIG_LIST -- $config_list"
  show_usage
  exit 1
fi
if [ -z "$config_list" -a -n "$config_dir" ]; then
  echo "$0: missing '-c CONFIG_LIST' option for given CONFIG_DIR -- $config_dir"
  show_usage
  exit 1
fi

# handle positional arguments
if [ $(($# - $OPTIND)) -ne 0 ]; then
  echo "$0: incorrect number of required arguments"
  show_usage
  exit 1
fi
box_name="${@:$OPTIND:1}"

# create/update some common directories that are mounted and may have root permissions
dir_init=".config .config/pulse .local .local/share .local/share/linuxbox"
dir_init+=" .local/share/linuxbox/$box_name Downloads"
uid=$(id -u)
gid=$(id -g)
echo_color "$fg_orange" "Fixing directory permissions in $HOME" >> $status_file
for d in $dir_init; do
  dir=$HOME/$d
  sudo mkdir -p $dir || true
  sudo chown $uid:$gid $dir || true
done
if [ -n "$(ls /run/user/$uid 2>/dev/null)" ]; then
  sudo chown $uid:$gid /run/user/$uid/* 2>/dev/null || true
fi

# run the distribution specific initialization scripts
if [ -r "$SCRIPT_DIR/init.sh" ]; then
  echo_color "$fg_orange" "Running distribution's system initialization script" >> $status_file
  sudo bash "$SCRIPT_DIR/init.sh"
fi
if [ -r "$SCRIPT_DIR/init-user.sh" ]; then
  echo_color "$fg_orange" "Running distribution's user initialization script" >> $status_file
  bash "$SCRIPT_DIR/init-user.sh"
fi

# process config files, application installs and invoke startup apps
if [ -n "$config_list" ]; then
  link_config_files
fi
if [ -n "$app_list" ]; then
  install_apps
fi
if [ -n "$startup_list" ]; then
  invoke_startup_apps
fi
# update the status file to indicate successful startup
echo started >> $status_file

# finally go into infinite wait using tail on /dev/null but handle TERM signal for clean exit
tail -s10 -f /dev/null &
childPID=$!

# truncate status file and cleanly kill the infinite wait on hup/int/quit/pipe/term signals
trap "echo -n > $status_file; kill -TERM $childPID" 1 2 3 13 15

wait $childPID
