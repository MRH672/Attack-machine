#!/usr/bin/env python

"""
Copyright (c) 2006-2025 Aya Maged
See the file 'LICENSE' for copying permission
"""

from plugins.generic.takeover import Takeover as GenericTakeover

class Takeover(GenericTakeover):
    def __init__(self):
        self.__basedir = None
        self.__datadir = None

        GenericTakeover.__init__(self)
