# /etc/bashrc

# System wide functions and aliases
# Environment stuff goes in /etc/profile

# It's NOT a good idea to change this file unless you know what you
# are doing. It's much better to create a custom.sh shell script in
# /etc/profile.d/ to make custom changes to your environment, as this
# will prevent the need for merging in future updates.

# are we an interactive shell?
if [ "$PS1" ]; then
  if [ -z "$PROMPT_COMMAND" ]; then
    case $TERM in
    xterm*)
        if [ -e /etc/sysconfig/bash-prompt-xterm ]; then
            PROMPT_COMMAND=/etc/sysconfig/bash-prompt-xterm
        else
            PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        fi
        ;;
    screen)
        if [ -e /etc/sysconfig/bash-prompt-screen ]; then
            PROMPT_COMMAND=/etc/sysconfig/bash-prompt-screen
        else
            PROMPT_COMMAND='printf "\033]0;%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        fi
        ;;
    *)
        [ -e /etc/sysconfig/bash-prompt-default ] && PROMPT_COMMAND=/etc/sysconfig/bash-prompt-default
        ;;
      esac
  fi
  # Turn on checkwinsize
  shopt -s checkwinsize
  [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@\h \W]\\$ "
  # You might want to have e.g. tty in prompt (e.g. more virtual machines)
  # and console windows
  # If you want to do so, just add e.g.
  # if [ "$PS1" ]; then
  #   PS1="[\u@\h:\l \W]\\$ "
  # fi
  # to your custom modification shell script in /etc/profile.d/ directory
fi

if ! shopt -q login_shell ; then # We're not a login shell
    # Need to redefine pathmunge, it get's undefined at the end of /etc/profile
    pathmunge () {
        case ":${PATH}:" in
            *:"$1":*)
                ;;
            *)
                if [ "$2" = "after" ] ; then
                    PATH=$PATH:$1
                else
                    PATH=$1:$PATH
                fi
        esac
    }

    # By default, we want umask to get set. This sets it for non-login shell.
    # Current threshold for system reserved uid/gids is 200
    # You could check uidgid reservation validity in
    # /usr/share/doc/setup-*/uidgid file
    if [ $UID -gt 199 ] && [ "`id -gn`" = "`id -un`" ]; then
       umask 002
    else
       umask 022
    fi

    # Only display echos from profile.d scripts if we are no login shell
    # and interactive - otherwise just process them to set envvars
    for i in /etc/profile.d/*.sh; do
        if [ -r "$i" ]; then
            if [ "$PS1" ]; then
                . "$i"
            else
                . "$i" >/dev/null 2>&1
            fi
        fi
    done

    unset i
    unset pathmunge
fi



PURPLE=$(tput setaf 129)
PINK=$(tput setaf 162)
RED=$(tput setaf 124)
ORANGE=$(tput setaf 208)
YELLOW=$(tput setaf 184)
GREEN=$(tput setaf 154)
BLUE=$(tput setaf 32)
GREY=$(tput setaf 242)
LIGHTGREY=$(tput setaf 249)

PRIMARY=${ORANGE}


function git_branch { 
    local branch=$(git branch 2>/dev/null|grep "*"|sed 's/* //')

    if [ -e $branch ]; then 
        return
    else
        if [ $branch == 'master' ]; then
            COLOR="${GREEN}"
        else
            COLOR="${PINK}"
        fi

        echo -e "${PRIMARY}(${GREY}±${COLOR}${branch}${PRIMARY}) "
    fi

}


function git_snippet { 
    if [[ -d ".git/" ]]; then
        local modified_files=$(git status -bs --porcelain 2> /dev/null | grep -E "M .+" | wc -l | tr -d ' ')
        local added_files=$(git status -bs --porcelain 2> /dev/null | grep -E "A .+" | wc -l | tr -d ' ')
        local removed_files=$(git status -bs --porcelain 2> /dev/null | grep -E "D .+" | wc -l | tr -d ' ')

        if [[ $modified_files -ne 0 ]]; then
            local GIT_MODDED="${GREY}| ${PINK}* ${modified_files} file(s) "
        fi
        
        if [[ $added_files -ne 0 ]]; then
            local GIT_ADDED="${GREY}| ${GREEN}+ ${added_files} file(s) "
        fi    

        if [[ $removed_files -ne 0 ]]; then
            local GIT_REMOVED="${GREY}| ${RED}- ${removed_files} file(s) "
        fi

        echo -e "Commit: ${GREY}$(git rev-parse --short HEAD) ${PRIMARY}${GIT_ADDED}${GIT_MODDED}${GIT_REMOVED}"
    fi
}

# Set Prompt Character
if [[ $EUID -ne 0 ]]; then
    PROMPT="%"
else
    PROMPT="#"
fi

#export PS1='${PRIMARY}\u$(tput setaf 7)@$(tput setaf 82)\h$(tput setaf 7): $(tput setaf 240)\w$(tput setaf 7)$ '
export PS1="\\n\\[\${PRIMARY}\\][\\[\$(tput setaf 242)\\]\\t\\[\${PRIMARY}\\]]    \\[\$(git_snippet)\\]\\n🚀  \\[\${PRIMARY}\\]\\u\\[\${GREY}\\]@\\[\${PRIMARY}\\]\\h\\[\$(tput setaf 7)\\]: \\[\$(tput setaf 240)\\]\\w \\[\$(git_branch)\\]\\[\$(tput sgr0)\\]${PROMPT} "
