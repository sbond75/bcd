#!/usr/bin/python

# Based on https://github.com/wodny/libbcd0

import uuid
import sys

import os
sys.path.append(os.path.join(os.path.dirname(__file__), "libbcd0"))

from libbcd0.mappings import *
from libbcd0.BCD import BCD
from libbcd0.BCDMenu import BCDMenu, BCDBootEntry

class BCDMyLinuxUpdater(object):
    mylinux_desc  = None
    mylinux_image = None
    menu_timeout = 20

    def __init__(self, filename):
        self.__bcdmenu = BCDMenu(filename)

    def __create_mylinux(self):
        guid = "{{{0}}}".format(uuid.uuid1())
        print("New GUID: {0}".format(guid))
        entry = BCDBootEntry(self.__bcdmenu.bcd, guid)
        entry.description = BCDMyLinuxUpdater.mylinux_desc
        win7 = self.__bcdmenu.find_bootentry_by_name("Windows 7")
        entry.boot_device = win7.boot_device
        entry.applicationpath = BCDMyLinuxUpdater.mylinux_image
        return entry

    def update(self):
        mylinux = self.__bcdmenu.find_bootentry_by_name(BCDMyLinuxUpdater.mylinux_desc)
        if mylinux is not None:
            self.__bcdmenu.delete_entry(mylinux)
        mylinux = self.__create_mylinux()
        self.__bcdmenu.add_entry(mylinux)
        self.__bcdmenu.timeout = BCDMyLinuxUpdater.menu_timeout
        self.__bcdmenu.commit()

    def print_info(self):
        print(dir(self.__bcdmenu.bcd))
        #self.__bcdmenu.bcd.print_tree(0)
        
        print("BCD information:")
        print("Timeout: {0}".format(self.__bcdmenu.timeout))
        print("Active boot entries:")
        for element in self.__bcdmenu.bootentries:
            print("  {0}".format(element.description))
            print("    {0}".format(element.guid))
            #print(element)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        #exit("Hive filename required.")
        filename = "/mnt/ramdisk/BCD"
    else:
        filename = sys.argv[1]

    mylinux = BCDMyLinuxUpdater(filename)
    print("Before changes:")
    mylinux.print_info()
    #print("")
    #mylinux.update()
    #print("")
    #print("After changes:")
    #mylinux.print_info()
