opennebula-exporter
===================

Prometheus exporter for OpenNebula

One day this will be a full-fledged exporter. For now, here's a quick hack:

1. Save this as e.g.: `/var/lib/one/vm_exporter`:
   ```
   #!/bin/sh

   FILE="/service/node_exporter/textfiles/opennebula.prom"
   /usr/bin/onevm list --csv | grep -v ID, | cut -d, -f5 | sort | uniq -c | awk '{ print "opennebula_vm_count{state=\"" $2 "\"} " $1 }' > "$FILE"
   ```

2. Add a cron job:
   ```
   * * * * * /var/lib/one/vm_exporter
   ```

3. Configure node_exporter to collect the file: add the `--collector.textfile.directory=/service/node_exporter/textfiles` flag. Make sure the directory exists and has correct permissions.

4. Enjoy your new shiny metric.
