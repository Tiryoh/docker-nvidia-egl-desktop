#!/bin/bash -e
USER=${USER:-root}
HOME=/root

# Create user with password ${PASSWD}
if [ "$USER" != "root" ]; then
    echo "* enable custom user: $USER"
    useradd --create-home --shell /bin/bash --user-group --groups adm,sudo,audio,video,dialout $USER
    echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    if [ -z "$PASSWD" ]; then
        echo "  set default password to \"ubuntu\""
        PASSWD=ubuntu
    fi
    HOME=/home/$USER
    echo "$USER:$PASSWD" | chpasswd
    chown -R $USER:$USER ${HOME}
    [ -d "/dev/snd" ] && chgrp -R adm /dev/snd
fi

if [ -z "$TZ" ]; then
    echo "  set default timezone to \"UTC\""
    TZ=UTC
fi
ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone

sed -i -e "s|%USER%|$USER|" -e "s|%HOME%|$HOME|" /etc/supervisord.conf
sed -i -e "s|%USER%|$USER|" -e "s|%HOME%|$HOME|" /etc/egl.yml

exec /bin/tini -- supervisord -n -c /etc/supervisord.conf
