opennebula-exporter
===================

Prometheus exporter for OpenNebula

One day this will be a full-fledged exporter. For now, here's a quick hack:

1. Save this as e.g. `/var/lib/one/opennebula_exporter`  and `chmod a+x`:
   ```sh
   #!/bin/sh
   
   /usr/bin/onevm   list --csv --list STAT | grep -v STAT | sort | uniq -c | awk '{ print "opennebula_vm_count{state=\"" $2 "\"} " $1 }' > "$FILE.tmp"
   /usr/bin/onehost list --csv --list STAT | grep -v STAT | sort | uniq -c | awk '{ print "opennebula_host_count{state=\"" $2 "\"} " $1 }' >> "$FILE.tmp"

   mv "$FILE.tmp" "$FILE"

   ```

2. Add a cron job:
   ```
   * * * * * /var/lib/one/opennebula_exporter
   ```

3. Configure node_exporter to collect the file: add the flag
   ```
   --collector.textfile.directory=/service/node_exporter/textfiles
   ```
   Make sure the directory exists and has correct permissions.

4. Enjoy your shiny new metric.
