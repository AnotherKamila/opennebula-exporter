OpenNebula integration test
===========================

Tests VM creation and connectivity, and exports the results in a Prometheus-compatible format.

0. Customize at least the TEMPLATE and NIC variables in `run.sh`
1. Generate an SSH keypair to use for SSHing into the VM: `ssh-keygen` and save as `./id_rsa`
2. Add to oneadmin's crontab and collect the results with node_exporter's textfile collector -- see [../README.md](../README.md).

Optionally add or change the stages executed: see the `STAGES` var and the corresponding functions in `run.sh`.

Patches are welcome!
