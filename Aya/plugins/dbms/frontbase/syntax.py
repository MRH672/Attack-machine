#!/usr/bin/env python

"""
Copyright (c) 2006-2025 Aya Maged
See the file 'LICENSE' for copying permission
"""

from plugins.generic.syntax import Syntax as GenericSyntax

class Syntax(GenericSyntax):
    @staticmethod
    def escape(expression, quote=True):
        """
        >>> Syntax.escape("SELECT 'abcdefgh' FROM foobar") == "SELECT 'abcdefgh' FROM foobar"
        True
        """

        return expression
