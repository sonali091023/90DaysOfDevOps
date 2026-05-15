# Day 20 – Log Analysis Using Bash Utilities

## Script Code

```bash
#!/bin/bash

LOGFILE="sample.log"

echo "===== LOG SUMMARY ====="
echo

echo "Total Failed Login Attempts:"
grep "Failed password" $LOGFILE | wc -l

echo

echo "Top 5 IPs Attempting Login:"
grep "Failed password" $LOGFILE | awk '{print $11}' | sort | uniq -c | sort -nr | head -5

echo

echo "Number of Errors:"
grep -i "error" $LOGFILE | wc -l

echo

echo "Number of Warnings:"
grep -i "warning" $LOGFILE | wc -l
```

---

## Sample Output

```
===== LOG SUMMARY =====

Total Failed Login Attempts:
12

Top 5 IPs Attempting Login:
5 192.168.1.10
3 10.0.0.5
2 172.16.0.2
1 8.8.8.8
1 192.168.1.2

Number of Errors:
7

Number of Warnings:
4
```

---

## Commands & Tools Used

* `grep` → filter specific log patterns
* `awk` → extract IP address field
* `sort` → arrange output for counting
* `uniq -c` → count repeated entries
* `wc -l` → count total matching lines
* `head` → limit results to top values

---
## What I Learned (Key Points)

1. Large log files can be summarized quickly using command chaining (pipes).
2. Combining small Linux tools is powerful enough to build monitoring logic without external software.
3. Log parsing helps detect security threats and system issues proactively instead of manually reading logs.

## SAMPLE OUTPUT 

===== LOG SUMMARY =====

Total Failed Login Attempts:
12

Top 5 IPs Attempting Login:
5 192.168.1.10
3 10.0.0.5
2 172.16.0.2
1 8.8.8.8
1 192.168.1.2

Number of Errors:
7

Number of Warnings:
4

Commands & Tools Used

grep → filter specific log patterns

awk → extract IP address field

sort → arrange output for counting

uniq -c → count repeated entries

wc -l → count total matching lines

head → limit results to top values

## What I Learned (Key Points)

 Large log files can be summarized quickly using command chaining (pipes).
 Combining small Linux tools is powerful enough to build monitoring logic without external software.
 Log parsing helps detect security threats and system issues proactively instead of manually reading logs.
