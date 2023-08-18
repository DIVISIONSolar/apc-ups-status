# These are automated notification scripts for the APC UPS

### Steps to setup are here: https://www.pontikis.net/blog/apc-ups-on-ubuntu-workstation



# How to setup

1. Install `sudo apt-get install ssmtp`
2. Enter your SMTP creds: `nano /etc/ssmtp/ssmtp.conf`

```
root=changeme@example.com
mailhub=smtp.example.com:587
AuthUser=your_username
AuthPass=your_password
UseTLS=YES # OR UseSTARTTLS=YES

```
3. Go to `/etc/apcupsd/` and edit the onbattery file. `nano /etc/apcupsd/onbattery`

it should look something like this:

```
#!/bin/sh
#
# This shell script if placed in /etc/apcupsd
# will be called by /etc/apcupsd/apccontrol when the UPS
# goes on batteries.
# We send an email message to root to notify him.
#

HOSTNAME=`hostname`
MSG="$HOSTNAME UPS $1 Power Failure !!!"
#
(
   echo "$MSG"
   echo " "
   /sbin/apcaccess status
) | $APCUPSD_MAIL -s "$MSG" $SYSADMIN
exit 0

```

you'll want yours to look like this:

```
#!/bin/sh
#
# This shell script if placed in /etc/apcupsd
# will be called by /etc/apcupsd/apccontrol when the UPS
# goes on batteries.
# We send an email message to root to notify him.
#

HOSTNAME=`hostname`
MSG="$HOSTNAME UPS $1 Power Failure !!!"
#
(
   echo "$MSG"
   echo " "
   /sbin/apcaccess status
) | $APCUPSD_MAIL -s "$MSG" $SYSADMIN
./etc/apcupsd/scripts/onbatt.sh
exit 0

```

4. Run these commands: `cd /etc/apcupsd/ && mkdir scripts && nano onbatt.sh`

then fill the `onbatt.sh` file with the contents from this github repo

5. Run these commands to grant permissions to the script and run it: `chmod +x ./onbatt.sh && ./onbatt.sh` and it should run some commands and send you the email! (it'll only send the email if the UPS has no power!)

# Setting up the battery alerts

1. Run these commands `nano /etc/apcupsd/scripts/lowbatt.sh` and fill it with the desired contents (do the same with the /etc/apcupsd/scripts/critlowbatt.sh).
2. Make sure to grant the right perms for the scripts: `chmod +x /etc/apcupsd/scripts/lowbatt.sh && chmod +x /etc/apcupsd/scripts/critlowbatt.sh`
3. Run this: `crontab -e` and scroll all the way to the bottom and paste these lines:

```
*/1 * * * * /bin/bash /etc/apcupsd/scripts/lowbatt.sh
*/1 * * * * /bin/bash /etc/apcupsd/scripts/critlowbatt.sh

```
and then `systemctl restart cron`

this will save the crontab file and start running the crons.

Want to change how often they run?

Go to: https://crontab.cronhub.io/

## If you need any help feel free to email me: `me@joshsevero.dev`
