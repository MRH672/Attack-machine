#!/usr/bin/env python

"""
Aya AM payloads trainer
=======================

سكربت بسيط علشان يساعدك تخلي ملف payloads.txt "يتعلم" من الأخطاء:
- تقدر تعلم على payload إنه فشل → يتم تعليقه (comment) في payloads.txt
- تقدر تسجّل نجاح/فشل في لوج بسيط am_payloads_log.txt

الاستخدام:
    python am_payloads_trainer.py --fail "AND 1=1"
    python am_payloads_trainer.py --fail-index 15
    python am_payloads_trainer.py --success "UNION ALL SELECT 1,2,3"
"""

from __future__ import print_function

import argparse
import os
import sys
from datetime import datetime

ROOT = os.path.dirname(os.path.abspath(__file__))
PAYLOADS_FILE = os.path.join(ROOT, "payloads.txt")
LOG_FILE = os.path.join(ROOT, "am_payloads_log.txt")


def _read_payloads():
    if not os.path.isfile(PAYLOADS_FILE):
        print("[!] payloads.txt not found at %s" % PAYLOADS_FILE)
        sys.exit(1)

    with open(PAYLOADS_FILE, "r", encoding="utf-8") as f:
        return f.readlines()


def _write_payloads(lines):
    with open(PAYLOADS_FILE, "w", encoding="utf-8") as f:
        f.writelines(lines)


def _log(status, payload):
    ts = datetime.utcnow().isoformat()
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write("[%s] %s: %s\n" % (ts, status.upper(), payload.strip()))


def mark_fail_by_value(value):
    lines = _read_payloads()
    changed = False

    for i, line in enumerate(lines):
        if line.strip() and not line.lstrip().startswith("#") and value.strip() in line:
            # علّق الـ payload بدل ما تمسحه تماماً
            lines[i] = "# FAIL: " + line
            changed = True

    if changed:
        _write_payloads(lines)
        _log("fail", value)
        print("[+] Marked matching payload(s) as FAIL in payloads.txt")
    else:
        print("[!] No matching payloads found for value: %s" % value)


def mark_fail_by_index(index):
    lines = _read_payloads()

    if index < 1 or index > len(lines):
        print("[!] Invalid index (1-%d)" % len(lines))
        return

    line = lines[index - 1]
    if line.lstrip().startswith("#"):
        print("[*] Line already commented, skipping")
        return

    lines[index - 1] = "# FAIL: " + line
    _write_payloads(lines)
    _log("fail", line)
    print("[+] Marked line %d as FAIL" % index)


def mark_success(value):
    _log("success", value)
    print("[+] Logged SUCCESS for payload: %s" % value.strip())


def main():
    parser = argparse.ArgumentParser(
        description="Aya AM payloads trainer (mark payloads as success/fail)",
    )

    parser.add_argument("--fail", dest="fail_value", help="Mark all payloads containing this value as FAIL")
    parser.add_argument("--fail-index", dest="fail_index", type=int, help="Mark payload at given line index (1-based) as FAIL")
    parser.add_argument("--success", dest="success_value", help="Log payload as SUCCESS")

    args = parser.parse_args()

    if not any((args.fail_value, args.fail_index, args.success_value)):
        parser.print_help()
        sys.exit(0)

    if args.fail_value:
        mark_fail_by_value(args.fail_value)

    if args.fail_index:
        mark_fail_by_index(args.fail_index)

    if args.success_value:
        mark_success(args.success_value)


if __name__ == "__main__":
    main()


