Ubiquiti Toolkit
================

Tools and various creations for Ubiquiti Admins and WISPs

Firmware Updater
----------------

Given the IP of an Access Point, it will update the firmware of all subscriber units. Make sure to have the firmware file downloaded and added in the folder of the script.

    firmware_update.rb (au ip)

DFS Unlocker
------------

Currently a single IP DFS unlocker for NSM5 units to unlock the UNII-2 band. You MUST have legally obtained a key from UBNT to make this application work properly.

    dfs_unlock.rb (subscriber ip)

Frequency
---------

Finds the Frequency and Bandwidth of a specified AU.

    frequency.rb (au ip)

Config (Beta)
-------------

Uploads a file of config changes and applies them to a unit. Only paramaters that need to be changed will need to be specified. 

WARNING - This code will eat your hamster if you give it a bad file, I have no idea what would happen. I'll put in safe guards later, but be warned of that.

    config_updater (au ip) (path/to/changes)

Planned Additions
=================

Currently working on a library to merge a lot of the base functionality and give the ability to easily generate scripts that can be run on entire sectors, networks or otherwise

