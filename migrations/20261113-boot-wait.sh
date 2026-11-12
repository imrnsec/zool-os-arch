#!/bin/bash
# خدمة ورثها النظام المثبّت من الفلاشة: تؤخر الإقلاع حتى تُضبط الساعة من الإنترنت
rm -f /etc/systemd/system/sysinit.target.wants/systemd-time-wait-sync.service
exit 0
