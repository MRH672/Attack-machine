#!/usr/bin/env python

"""
Copyright (c) 2025 Aya Elbadry (@Aya-Elbadry)
See the file 'LICENSE' for copying permission
"""

from lib.core.data import logger

from plugins.generic.enumeration import Enumeration as GenericEnumeration

class Enumeration(GenericEnumeration):
    def getHostname(self):
        warnMsg = "on PostgreSQL it is not possible to enumerate the hostname"
        logger.warning(warnMsg)
