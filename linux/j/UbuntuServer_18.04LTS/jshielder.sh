#!/bin/bash

# JShielder v2.4
# Deployer for Ubuntu Server 18.04 LTS
#
# Jason Soto
# www.jasonsoto.com
# www.jsitech-sec.com
# Twitter = @JsiTech

# Based from JackTheStripper Project
# Credits to Eugenia Bahit

# A lot of Suggestion Taken from The Lynis Project
# www.cisofy.com/lynis
# Credits to Michael Boelen @mboelen

#Credits to Center for Internet Security CIS


source helpers.sh

##############################################################################################################

f_banner(){
    echo
    echo "

    ██╗███████╗██╗  ██╗██╗███████╗██╗     ██████╗ ███████╗██████╗
    ██║██╔════╝██║  ██║██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗
    ██║███████╗███████║██║█████╗  ██║     ██║  ██║█████╗  ██████╔╝
    ██   ██║╚════██║██╔══██║██║██╔══╝  ██║     ██║  ██║██╔══╝  ██╔══██╗
    ╚█████╔╝███████║██║  ██║██║███████╗███████╗██████╔╝███████╗██║  ██║
    ╚════╝ ╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝

    For Ubuntu Server 18.04 LTS
        Developed By Jason Soto @Jsitech"
        echo
        echo

    }

##############################################################################################################

# Check if running with root User

clear
f_banner


check_root() {
    if [ "$USER" != "root" ]; then
        echo "Permission Denied"
        echo "Can only be run by root"
        exit
    else
        clear
        f_banner
        jshielder_home=$(pwd)
        cat templates/texts/welcome
    fi
}

##############################################################################################################

# Installing Dependencies
# Needed Prerequesites will be set up here
install_dep(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Setting some Prerequisites"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    spinner
    add-apt-repository universe
    say_done
}

##############################################################################################################

# Update System, Install sysv-rc-conf tool
update_system(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Updating the System"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt update
    apt upgrade -y
    apt dist-upgrade -y
    say_done
}

##############################################################################################################

# Setting a more restrictive UMASK
restrictive_umask(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Setting UMASK to a more Restrictive Value (027)"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    spinner
    cp templates/login.defs /etc/login.defs
    echo ""
    echo "OK"
    say_done
}

#############################################################################################################

#Disabling Unused Filesystems

unused_filesystems(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Disabling Unused FileSystems"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    spinner
    echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf
    echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf
    echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf
    echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf
    echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf
    echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf
    echo "install udf /bin/true" >> /etc/modprobe.d/CIS.conf
    echo "install vfat /bin/true" >> /etc/modprobe.d/CIS.conf
    echo " OK"
    say_done
}

##############################################################################################################

uncommon_netprotocols(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Disabling Uncommon Network Protocols"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    spinner
    echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf
    echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf
    echo "install rds /bin/true" >> /etc/modprobe.d/CIS.conf
    echo "install tipc /bin/true" >> /etc/modprobe.d/CIS.conf
    echo " OK"
    say_done

}

##############################################################################################################

#Securing /tmp Folder
secure_tmp(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Securing /tmp Folder"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo -n " ¿Did you Create a Separate /tmp partition during the Initial Installation? (y/n): "; read tmp_answer
    if [ "$tmp_answer" == "n" ]; then
        echo "We will create a FileSystem for the /tmp Directory and set Proper Permissions "
        spinner
        dd if=/dev/zero of=/usr/tmpDISK bs=1024 count=2048000
        mkdir /tmpbackup
        cp -Rpf /tmp /tmpbackup
        mount -t tmpfs -o loop,noexec,nosuid,rw /usr/tmpDISK /tmp
        chmod 1777 /tmp
        cp -Rpf /tmpbackup/* /tmp/
        rm -rf /tmpbackup
        echo "/usr/tmpDISK  /tmp    tmpfs   loop,nosuid,nodev,noexec,rw  0 0" >> /etc/fstab
        sudo mount -o remount /tmp
        say_done
    else
        echo "Nice Going, Remember to set proper permissions in /etc/fstab"
        echo ""
        echo "Example:"
        echo ""
        echo "/dev/sda4   /tmp   tmpfs  loop,nosuid,noexec,rw  0 0 "
        say_done
        fi
    }

##############################################################################################################

# Secure SSH
secure_ssh(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Securing SSH"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo -n " Securing SSH..."
    spinner
    sed s/USERNAME/$username/g templates/sshd_config > /etc/ssh/sshd_config; echo "OK"
    chattr -i /home/$username/.ssh/authorized_keys
    service ssh restart
    say_done
}

##############################################################################################################

# Install fail2ban
# To Remove a Fail2Ban rule use:
# iptables -D fail2ban-ssh -s IP -j DROP
install_fail2ban(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing Fail2Ban"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt install sendmail
    apt install fail2ban
    say_done
}

##############################################################################################################

# Configure fail2ban
config_fail2ban(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Configuring Fail2Ban"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo " Configuring Fail2Ban......"
    spinner
    sed s/MAILTO/$inbox/g templates/fail2ban > /etc/fail2ban/jail.local
    cp /etc/fail2ban/jail.local /etc/fail2ban/jail.conf
    /etc/init.d/fail2ban restart
    say_done
}

##############################################################################################################

# Tune and Secure Kernel
tune_secure_kernel(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Tuning and Securing the Linux Kernel"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo " Securing Linux Kernel"
    spinner
    echo "* hard core 0" >> /etc/security/limits.conf
    cp templates/sysctl.conf /etc/sysctl.conf; echo " OK"
    cp templates/ufw /etc/default/ufw
    sysctl -e -p
    say_done
}

##############################################################################################################

# Install RootKit Hunter
install_rootkit_hunter(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing RootKit Hunter"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo "Rootkit Hunter is a scanning tool to ensure you are you're clean of nasty tools. This tool scans for rootkits, backdoors and local exploits by running tests like:

    - MD5 hash compare
    - Look for default files used by rootkits
    - Wrong file permissions for binaries
    - Look for suspected strings in LKM and KLD modules
    - Look for hidden files
    - Optional scan within plaintext and binary files "
    sleep 1
    cd rkhunter-1.4.6/
    sh installer.sh --layout /usr --install
    cd ..
    rkhunter --update
    rkhunter --propupd
    echo ""
    echo " ***To Run RootKit Hunter ***"
    echo "     rkhunter -c --enable all --disable none"
    echo "     Detailed report on /var/log/rkhunter.log"
    say_done
}

##############################################################################################################

# Install PortSentry
install_portsentry(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing PortSentry"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt install portsentry
    mv /etc/portsentry/portsentry.conf /etc/portsentry/portsentry.conf-original
    cp templates/portsentry /etc/portsentry/portsentry.conf
    sed s/tcp/atcp/g /etc/default/portsentry > salida.tmp
    mv salida.tmp /etc/default/portsentry
    /etc/init.d/portsentry restart
    say_done
}

##############################################################################################################

# Install and Configure Artillery
install_artillery (){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Cloning Repo and Installing Artillery"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    git clone https://github.com/BinaryDefense/artillery
    cd artillery/
    python setup.py
    cd ..
    echo ""
    echo "Setting Iptable rules for artillery"
    spinner
    #for port in 22 1433 8080 21 5900 53 110 1723 1337 10000 5800 44443 16993; do
    #echo "iptables -A INPUT -p tcp -m tcp --dport $port -j ACCEPT" >> /etc/init.d/iptables.sh
    #done
    echo ""
    echo "Artillery configuration file is /var/artillery/config"
    say_done
}
##############################################################################################################

# Additional Hardening Steps
additional_hardening(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Running additional Hardening Steps"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo "Running Additional Hardening Steps...."
    spinner
    echo tty1 > /etc/securetty
    chmod 0600 /etc/securetty
    chmod 700 /root
    chmod 600 /boot/grub/grub.cfg
    #Remove AT and Restrict Cron
    apt purge at
    apt install -y libpam-cracklib
    echo ""
    echo " Securing Cron "
    spinner
    touch /etc/cron.allow
    chmod 600 /etc/cron.allow
    awk -F: '{print $1}' /etc/passwd | grep -v root > /etc/cron.deny
    echo ""
    echo -n " Do you want to Disable USB Support for this Server? (y/n): " ; read usb_answer
    if [ "$usb_answer" == "y" ]; then
        echo ""
        echo "Disabling USB Support"
        spinner
        echo "blacklist usb-storage" | sudo tee -a /etc/modprobe.d/blacklist.conf
        update-initramfs -u
        echo "OK"
        say_done
    else
        echo "OK"
        say_done
    fi
}

##############################################################################################################

# Install Unhide
install_unhide(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing UnHide"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo "Unhide is a forensic tool to find hidden processes and TCP/UDP ports by rootkits / LKMs or by another hidden technique."
    sleep 1
    apt -y install unhide
    echo ""
    echo " Unhide is a tool for Detecting Hidden Processes "
    echo " For more info about the Tool use the manpages "
    echo " man unhide "
    say_done
}

##############################################################################################################

# Install Tiger
#Tiger is and Auditing and Intrusion Detection System
install_tiger(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing Tiger"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo "Tiger is a security tool that can be use both as a security audit and intrusion detection system"
    sleep 1
    apt -y install tiger
    echo ""
    echo " For More info about the Tool use the ManPages "
    echo " man tiger "
    say_done
}

##############################################################################################################

#Install PSAD
#PSAD actively monitors firewall logs to determine if a scan or attack is taking place
install_psad(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Install PSAD"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo " PSAD is a piece of Software that actively monitors you Firewall Logs to Determine if a scan
    or attack event is in Progress. It can alert and Take action to deter the Threat

    NOTE:
    IF YOU ARE ONLY RUNNING THIS FUNCTION, YOU MUST ENABLE LOGGING FOR iptables

        iptables -A INPUT -j LOG
        iptables -A FORWARD -j LOG

        "
        echo ""
        echo -n " Do you want to install PSAD (Recommended)? (y/n): " ; read psad_answer
        if [ "$psad_answer" == "y" ]; then
            echo -n " Type an Email Address to Receive PSAD Alerts: " ; read inbox1
            apt install psad
            sed -i s/INBOX/$inbox1/g templates/psad.conf
            sed -i s/CHANGEME/$host_name.$domain_name/g templates/psad.conf
            cp templates/psad.conf /etc/psad/psad.conf
            psad --sig-update
            service psad restart
            echo "Installation and Configuration Complete"
            echo "Run service psad status, for detected events"
            echo ""
            say_done
        else
            echo "OK"
            say_done
        fi
    }

##############################################################################################################


# Disable Compilers
disable_compilers(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Disabling Compilers"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo "Disabling Compilers....."
    spinner
    chmod 000 /usr/bin/as >/dev/null 2>&1
    chmod 000 /usr/bin/byacc >/dev/null 2>&1
    chmod 000 /usr/bin/yacc >/dev/null 2>&1
    chmod 000 /usr/bin/bcc >/dev/null 2>&1
    chmod 000 /usr/bin/kgcc >/dev/null 2>&1
    chmod 000 /usr/bin/cc >/dev/null 2>&1
    chmod 000 /usr/bin/gcc >/dev/null 2>&1
    chmod 000 /usr/bin/*c++ >/dev/null 2>&1
    chmod 000 /usr/bin/*g++ >/dev/null 2>&1
    spinner
    echo ""
    echo " If you wish to use them, just change the Permissions"
    echo " Example: chmod 755 /usr/bin/gcc "
    echo " OK"
    say_done
}

##############################################################################################################

# Additional Security Configurations
#Enable Unattended Security Updates
unattended_upgrades(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Enable Unattended Security Updates"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo -n " ¿Do you Wish to Enable Unattended Security Updates? (y/n): "; read unattended
    if [ "$unattended" == "y" ]; then
        dpkg-reconfigure -plow unattended-upgrades
    else
        clear
    fi
}

##############################################################################################################

# Enable Process Accounting
enable_proc_acct(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Enable Process Accounting"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt install acct
    touch /var/log/wtmp
    echo "OK"
}

##############################################################################################################

#Install and enable auditd

install_auditd(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing auditd"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt install auditd

  # Using CIS Benchmark configuration

  #Ensure auditing for processes that start prior to auditd is enabled
  echo ""
  echo "Enabling auditing for processes that start prior to auditd"
  spinner
  sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="audit=1"/g' /etc/default/grub
  update-grub

  echo ""
  echo "Configuring Auditd Rules"
  spinner

  cp templates/audit-CIS.rules /etc/audit/rules.d/audit.rules

  find / -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print \
      "-a always,exit -F path=" $1 " -F perm=x -F auid>=1000 -F auid!=4294967295 \
      -k privileged" } ' >> /etc/audit/rules.d/audit.rules

  echo " " >> /etc/audit/rules.d/audit.rules
  echo "#End of Audit Rules" >> /etc/audit/rules.d/audit.rules
  echo "-e 2" >>/etc/audit/rules.d/audit.rules

  systemctl enable auditd.service
  service auditd restart
  echo "OK"
  say_done
}
##############################################################################################################

#Install and Enable sysstat

install_sysstat(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing and enabling sysstat"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt install sysstat
    sed -i 's/ENABLED="false"/ENABLED="true"/g' /etc/default/sysstat
    service sysstat start
    echo "OK"
    say_done
}

##############################################################################################################

#Install ArpWatch

install_arpwatch(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m ArpWatch Install"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo "ArpWatch is a tool for monitoring ARP traffic on System. It generates log of observed pairing of IP and MAC."
    echo ""
    echo -n " Do you want to Install ArpWatch on this Server? (y/n): " ; read arp_answer
    if [ "$arp_answer" == "y" ]; then
        echo "Installing ArpWatch"
        spinner
        apt install -y arpwatch
        systemctl enable arpwatch.service
        service arpwatch start
        echo "OK"
        say_done
    else
        echo "OK"
        say_done
    fi
}

##############################################################################################################

set_grubpassword(){
    clear
    echo -e "Securing Boot Settings"
    spinner
    sleep 2
    chown root:root /boot/grub/grub.cfg
    chmod og-rwx /boot/grub/grub.cfg
    say_done

}

##############################################################################################################

file_permissions(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Setting File Permissions on Critical System Files"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    spinner
    sleep 2
    chmod -R g-wx,o-rwx /var/log/*

    chown root:root /etc/ssh/sshd_config
    chmod og-rwx /etc/ssh/sshd_config

    chown root:root /etc/passwd
    chmod 644 /etc/passwd

    chown root:shadow /etc/shadow
    chmod o-rwx,g-wx /etc/shadow

    chown root:root /etc/group
    chmod 644 /etc/group

    chown root:shadow /etc/gshadow
    chmod o-rwx,g-rw /etc/gshadow

    chown root:root /etc/passwd-
    chmod 600 /etc/passwd-

    chown root:root /etc/shadow-
    chmod 600 /etc/shadow-

    chown root:root /etc/group-
    chmod 600 /etc/group-

    chown root:root /etc/gshadow-
    chmod 600 /etc/gshadow-


    echo -e ""
    echo -e "Setting Sticky bit on all world-writable directories"
    sleep 2
    spinner

    df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t

    echo " OK"
    say_done

}
##############################################################################################################

clear
f_banner
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo -e "\e[93m[+]\e[00m SELECT THE DESIRED OPTION"
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo ""
echo "1. LAMP Deployment"
echo "2. LEMP Deployment"
echo "3. Reverse Proxy Deployment With Apache"
echo "4. General Purpose (without WebServer or DBServer)"
echo "5. Running With SecureWPDeployer or JSDeployer Script"
echo "6. Customized Run (Only run desired Options)"
echo "7. Custom"
echo "8. CIS Benchmark Hardening"
echo "9. Exit"
echo

read choice

case $choice in

    1)
        check_root
        install_dep
        config_host
        config_timezone
        update_system
        restrictive_umask
        unused_filesystems
        uncommon_netprotocols
        admin_user
        rsa_keygen
        rsa_keycopy
        secure_ssh
        set_iptables
        install_fail2ban
        install_secure_mysql
        install_apache
        install_secure_php
        install_modsecurity
        set_owasp_rules
        secure_optimize_apache
        install_modevasive
        install_qos_spamhaus
        config_fail2ban
        additional_packages
        tune_secure_kernel
        install_rootkit_hunter
        tune_nano_vim_bashrc
        daily_update_cronjob
        install_artillery
        additional_hardening
        install_unhide
        install_tiger
        install_psad
        disable_compilers
        secure_tmp
        apache_conf_restrictions
        unattended_upgrades
        enable_proc_acct
        install_auditd
        install_sysstat
        install_arpwatch
        set_grubpassword
        file_permissions
        reboot_server
        ;;


    2)
        check_root
        install_dep
        config_host
        config_timezone
        update_system
        restrictive_umask
        unused_filesystems
        uncommon_netprotocols
        admin_user
        rsa_keygen
        rsa_keycopy
        secure_ssh
        set_iptables
        install_fail2ban
        install_secure_mysql
        install_nginx
        compile_modsec_nginx
        install_secure_php_nginx
        config_fail2ban
        additional_packages
        tune_secure_kernel
        install_rootkit_hunter
        tune_nano_vim_bashrc
        daily_update_cronjob
        install_artillery
        additional_hardening
        install_unhide
        install_tiger
        install_psad
        disable_compilers
        secure_tmp
        unattended_upgrades
        enable_proc_acct
        install_auditd
        install_sysstat
        install_arpwatch
        set_grubpassword
        file_permissions
        reboot_server
        ;;

    3)
        check_root
        install_dep
        config_host
        config_timezone
        update_system
        restrictive_umask
        unused_filesystems
        uncommon_netprotocols
        admin_user
        rsa_keygen
        rsa_keycopy
        secure_ssh
        set_iptables
        install_fail2ban
        install_apache
        install_modsecurity
        set_owasp_rules
        secure_optimize_apache
        install_modevasive
        install_qos_spamhaus
        config_fail2ban
        additional_packages
        tune_secure_kernel
        install_rootkit_hunter
        tune_nano_vim_bashrc
        daily_update_cronjob
        install_artillery
        additional_hardening
        install_unhide
        install_tiger
        install_psad
        disable_compilers
        secure_tmp
        apache_conf_restrictions
        unattended_upgrades
        enable_proc_acct
        install_auditd
        install_sysstat
        install_arpwatch
        set_grubpassword
        file_permissions
        reboot_server
        ;;

    4)
        check_root
        install_dep
        config_host
        config_timezone
        update_system
        restrictive_umask
        unused_filesystems
        uncommon_netprotocols
        admin_user
        rsa_keygen
        rsa_keycopy
        secure_ssh
        set_iptables
        install_fail2ban
        config_fail2ban
        additional_packages
        tune_secure_kernel
        install_rootkit_hunter
        tune_nano_vim_bashrc
        daily_update_cronjob
        install_artillery
        additional_hardening
        install_unhide
        install_tiger
        install_psad
        disable_compilers
        secure_tmp
        unattended_upgrades
        enable_proc_acct
        install_auditd
        install_arpwatch
        set_grubpassword
        file_permissions
        ;;


    5)
        check_root
        install_dep
        config_host
        config_timezone
        update_system
        restrictive_umask
        unused_filesystems
        uncommon_netprotocols
        admin_user
        rsa_keygen
        rsa_keycopy
        secure_ssh
        set_iptables
        install_fail2ban
        install_secure_mysql
        install_apache
        install_secure_php
        install_modsecurity
        set_owasp_rules
        secure_optimize_apache
        install_modevasive
        install_qos_spamhaus
        config_fail2ban
        additional_packages
        tune_secure_kernel
        install_rootkit_hunter
        tune_nano_vim_bashrc
        daily_update_cronjob
        install_artillery
        additional_hardening
        install_unhide
        install_tiger
        install_psad
        disable_compilers
        secure_tmp
        apache_conf_restrictions
        unattended_upgrades
        enable_proc_acct
        install_auditd
        install_sysstat
        install_arpwatch
        set_grubpassword
        file_permissions
        ;;

    7)
        check_root
        install_dep
        update_system
        restrictive_umask
        unused_filesystems
        uncommon_netprotocols
        secure_tmp
        secure_ssh
        install_fail2ban
        config_fail2ban
        tune_secure_kernel
        install_rootkit_hunter
        install_portsentry
        install_artillery
        additional_hardening
        install_unhide
        install_tiger
        install_psad
        disable_compilers
        enable_proc_acct
        enable_proc_acct
        install_auditd
        install_sysstat
        install_arpwatch
        set_grubpassword
        file_permissions
        chmod +x jshielder-CIS.sh
        ./jshielder-CIS.sh
        ;;

    8)

        menu=""
        until [ "$menu" = "34" ]; do

            clear
            f_banner
            echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
            echo -e "\e[93m[+]\e[00m SELECT THE DESIRED OPTION"
            echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
            echo ""
            echo "1. Configure Host Name, Create Legal Banners, Update Hosts Files"
            echo "2. Configure Timezone"
            echo "3. Update System"
            echo "4. Create Admin User"
            echo "5. Instructions to Generate and move Private/Public key Pair"
            echo "6. Secure SSH Configuration"
            echo "7. Set Restrictive IPTable Rules"
            echo "8. Install and Configure Fail2Ban"
            echo "9. Install, Optimize and Secure Apache"
            echo "10. Install Nginx with ModSecurity Module and Set OwaspRules"
            echo "11. Set Nginx Vhost with PHP"
            echo "12. Set Nginx Vhost"
            echo "13. Install and Secure PHP for Apache Server"
            echo "14. Install and Secure PHP for Nginx Server"
            echo "15. Install ModSecurity (Apache)and Set Owasp Rules"
            echo "16. Install ModEvasive"
            echo "17. Install ModQos and SpamHaus"
            echo "18. Tune and Secure Linux Kernel"
            echo "19. Install RootKit Hunter"
            echo "20. Tune Vim, Nano, Bashrc"
            echo "21. Install PortSentry"
            echo "22. Secure tty, root home, grub configs, cron"
            echo "23. Install Unhide"
            echo "24. Install Tiger"
            echo "25. Disable Compilers"
            echo "26. Enable Unnatended Upgrades"
            echo "27. Enable Process Accounting"
            echo "28. Install PHP Suhosin (Disabled for Now)"
            echo "29. Install and Secure MySQL"
            echo "30. Set More Restrictive UMASK Value (027)"
            echo "31. Secure /tmp Directory"
            echo "32. Install PSAD IDS"
            echo "33. Set GRUB Bootloader Password"
            echo "34. Exit"
            echo " "

            read menu
            case $menu in

                1)
                    config_host
                    ;;

                2)
                    config_timezone
                    ;;

                3)
                    update_system
                    ;;

                4)
                    admin_user
                    ;;

                5)
                    rsa_keygen
                    rsa_keycopy
                    ;;

                6)
                    echo "key Pair must be created "
                    echo "What user will have access via SSH? " ; read username
                    rsa_keygen
                    rsa_keycopy
                    secure_ssh
                    ;;

                7)
                    set_iptables
                    ;;

                8)
                    echo "Type Email to receive Alerts: " ; read inbox
                    install_fail2ban
                    config_fail2ban
                    ;;

                9)
                    install_apache
                    secure_optimize_apache
                    apache_conf_restrictions
                    ;;

                10)
                    install_nginx_modsecurity
                    set_nginx_modsec_OwaspRules
                    ;;

                11)
                    set_nginx_vhost
                    ;;


                12)
                    set_nginx_vhost_nophp
                    ;;

                13)
                    install_secure_php
                    ;;

                14)
                    install_php_nginx
                    ;;

                15)
                    install_modsecurity
                    set_owasp_rules
                    ;;

                16)
                    install_modevasive
                    ;;

                17)
                    install_qos_spamhaus
                    ;;

                18)
                    tune_secure_kernel
                    ;;

                19)
                    install_rootkit_hunter
                    ;;

                20)
                    tune_nano_vim_bashrc
                    ;;

                21)
                    install_portsentry
                    ;;

                22)
                    additional_hardening
                    ;;

                23)
                    install_unhide
                    ;;

                24)
                    install_tiger
                    ;;

                25)
                    disable_compilers;
                    ;;

                26)
                    unattended_upgrades
                    ;;

                27)
                    enable_proc_acct
                    ;;

                #28)
                    #install_phpsuhosin
                    #;;

                29)
                    install_secure_mysql
                    ;;

                30)
                    restrictive_umask
                    ;;

                31)
                    secure_tmp
                    ;;

                32)
                    install_psad
                    ;;

                33)
                    set_grubpassword
                    ;;

                34)
                    break ;;

                *) ;;

            esac
        done
        ;;

    8)
        chmod +x jshielder-CIS.sh
        ./jshielder-CIS.sh
        ;;


    9)
        exit 0
        ;;

    esac
    ##############################################################################################################

