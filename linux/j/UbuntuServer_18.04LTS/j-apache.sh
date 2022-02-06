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

# Install Apache
install_apache(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing Apache Web Server"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt install apache2
    say_done
}

##############################################################################################################

# Install ModSecurity
install_modsecurity(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing ModSecurity"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt install libxml2 libxml2-dev libxml2-utils
    apt install libaprutil1 libaprutil1-dev
    apt install libapache2-mod-security2
    service apache2 restart
    say_done
}

##############################################################################################################

# Configure OWASP ModSecurity Core Rule Set (CRS3)
set_owasp_rules(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Setting UP OWASP ModSecurity Core Rule Set (CRS3)"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""

    #for archivo in /usr/share/modsecurity-crs/base_rules/*
    #   do ln -s $archivo /usr/share/modsecurity-crs/activated_rules/
    #done

    #for archivo in /usr/share/modsecurity-crs/optional_rules/*
    #    do ln -s $archivo /usr/share/modsecurity-crs/activated_rules/
    #done
    spinner
    echo "OK"

    sed s/SecRuleEngine\ DetectionOnly/SecRuleEngine\ On/g /etc/modsecurity/modsecurity.conf-recommended > salida
    mv salida /etc/modsecurity/modsecurity.conf

    echo 'SecServerSignature "AntiChino Server 1.0.4 LS"' >> /usr/share/modsecurity-crs/modsecurity_crs_10_setup.conf
    echo 'Header set X-Powered-By "Plankalkül 1.0"' >> /usr/share/modsecurity-crs/modsecurity_crs_10_setup.conf
    echo 'Header set X-Mamma "Mama mia let me go"' >> /usr/share/modsecurity-crs/modsecurity_crs_10_setup.conf

    a2enmod headers
    service apache2 restart
    say_done
}

##############################################################################################################

# Configure and optimize Apache
secure_optimize_apache(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Optimizing Apache"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    cp templates/apache /etc/apache2/apache2.conf
    echo " -- Enabling ModRewrite"
    spinner
    a2enmod rewrite
    service apache2 restart
    say_done
}

##############################################################################################################

# Install ModEvasive
install_modevasive(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing ModEvasive"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo -n " Type Email to Receive Alerts "; read inbox
    apt install libapache2-mod-evasive
    mkdir /var/log/mod_evasive
    chown www-data:www-data /var/log/mod_evasive/
    sed s/MAILTO/$inbox/g templates/mod-evasive > /etc/apache2/mods-available/mod-evasive.conf
    service apache2 restart
    say_done
}

##############################################################################################################

# Install Mod_qos/spamhaus
install_qos_spamhaus(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing Mod_Qos/Spamhaus"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt -y install libapache2-mod-qos
    cp templates/qos /etc/apache2/mods-available/qos.conf
    apt -y install libapache2-mod-spamhaus
    cp templates/spamhaus /etc/apache2/mods-available/spamhaus.conf
    service apache2 restart
    say_done
}

check_root
install_apache
install_modsecurity
set_owasp_rules
secure_optimize_apache
install_modevasive
install_qos_spamhaus
