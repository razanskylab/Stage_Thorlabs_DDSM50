# thorlabs_ddsm50-m
Thorlabs DDSM50/M

This class can be used to control a DDSM50 or DDSM50/M stage by Thorlabs using an easy MATLAB interface taking care of most of the background work like connecting, disconnecting, settings accelerations according to mass etc. Since it is based on the .NET interface, please download and install Kinesis first:

https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0

**Common issues**

*Variable names*

Thorlabs changed the name of some variables with the Update to version 1.14.15. If you are using an earlier version you might need to rename some variables.

*Serial number*

The function `List_Devices.m` returns the available devices. Use this number as your `serialnumber`.

*Enabling takes two attempts*

Known issue without any solution yet. Recommendations welcome.
