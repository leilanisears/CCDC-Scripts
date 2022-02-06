#!/bin/bash
# fail2ban ssh
apt update && \
    apt install fail2ban && \
    echo '[sshd]' > /etc/fail2ban/jail.local && \
    echo 'enabled = true' >> /etc/fail2ban/jail.local && \
    echo 'banaction = iptables-multiport' >> /etc/fail2ban/jail.local && \
    echo 'maxretry = 6' >> /etc/fail2ban/jail.local && \
    echo 'findtime = 60' >> /etc/fail2ban/jail.local && \
    echo 'bantime = 300' >> /etc/fail2ban/jail.local && \
    systemctl restart fail2ban
