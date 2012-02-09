function startvm () {
  if [ -z "$1" ]; then
  	echo "missing guest"
  	exit 1
  fi
  echo "Starting $1..."
  _startvm "$1"&>/dev/null
  sleep 30
  mkdir /Volumes/"$1"
  sshfs "$1":/var/www /Volumes/"$1" -o cache=no,volname="$1" &>/dev/null
  if [ -n "$2" ]; then
  	mate /Volumes/"$1"/"$2"
  fi
}

function stopvm () {
  if [ -z "$1" ]; then
  	echo "missing guest"
  	exit 1
  fi
  echo "Stopping $1..."
  _stopvm "$1"&>/dev/null
  sleep 10
}

function _startvm () {
  nohup VBoxHeadless -s "$1"&>/dev/null &
} &>/dev/null

function _stopvm () {
  umount /Volumes/"$1"
  ssh "$1" 'sudo halt'
} &>/dev/null

function mrf () {
  if [ -z "$1" ]; then
  	echo "missing remote [host:/foo/bar]"
  	exit 1
  fi

  remote=$1
  host=${remote/\:*/}
  folder=${remote/*\:/}

  if [ -n "$2" ]
  	then mount_point=$2
  	else mount_point=$host${folder//\//\-}
  fi

  mkdir /Volumes/$mount_point
  #echo "Mounting ${host}:${folder} into /Volumes/${mount_point}"
  sshfs $host:$folder /Volumes/$mount_point -o cache=no,follow_symlinks,volname=$mount_point &>/dev/null
}

_list_vms () {
   local cur prev base
   COMPREPLY=()
   cur="${COMP_WORDS[COMP_CWORD]}"
   prev="${COMP_WORDS[COMP_CWORD-1]}"
   local projects=$(ls ~/VirtualBox\ VMs)
   COMPREPLY=( $(compgen -W "${projects}" -- ${cur}) )
   return 0
}
complete -F _list_vms startvm
complete -F _list_vms stopvm


alias ll="ls -l"
alias la="ls -la"
alias m="mate"