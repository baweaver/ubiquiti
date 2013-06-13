ubiquiti
========

Tools and various creations for Ubiquiti Admins and WISPs

Firmware Updater
----------------

Given the IP of an Access Point, it will update the firmware of all subscriber units. Make sure to have the firmware file downloaded and added in the folder of the script.

Usage: firmware_update.rb (au ip)

DFS Unlocker
------------

Currently a single IP DFS unlocker for NSM5 units to unlock the UNII-2 band. You MUST have legally obtained a key from UBNT to make this application work properly.

Usage: dfs_unlock.rb (subscriber ip)
