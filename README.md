opennebula-exporter
===================

Prometheus exporter for OpenNebula

One day this will be a full-fledged exporter. For now, here's a quick hack:

1. Save this as e.g. `/var/lib/one/opennebula_exporter`  and `chmod a+x`:
   ```sh
   #!/usr/bin/env sh
   
   /usr/bin/onevm   list --csv --list STAT | awk '!/STAT/ { stat[$0] += 1 } END { for (i in stat) print "opennebula_vm_count{state=\""i"\"}", stat[i] }' | sort > "$FILE.tmp"
   /usr/bin/onehost list --csv --list STAT | awk '!/STAT/ { stat[$0] += 1 } END { for (i in stat) print "opennebula_host_count{state=\""i"\"}", stat[i] }' | sort >> "$FILE.tmp"

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

