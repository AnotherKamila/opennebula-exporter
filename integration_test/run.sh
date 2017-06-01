#!/bin/sh

NAME='integration_test'
TEMPLATE='internal-Debian 8'
NIC='vm-internal'
SSHPUB='./id_rsa.pub'
SSHKEY='./id_rsa'

STATS_FILE='/service/node_exporter/textfiles/opennebula_backend_integration_test.prom'
METRIC='opennebula_backend_integration_test'

STAGES="create ping_in ssh_in ping_out http_out cleanup"

set -e  # exit on error
cd "$(dirname "$0")"

F="$STATS_FILE.tmp"
: > "$F"

get_attr() {
	onevm list --csv --filter ID=$1 --list ID,$2 | grep -v $2 | cut -d, -f2
}

ID=""
IP=""

###################

create() {
	ID=$(onetemplate instantiate "$TEMPLATE" --net_context --name "$NAME" --nic "$NIC" --ssh "$SSHPUB" | sed -nE 's/VM ID: ([0-9]+)/\1/p')
	[ -z $ID ] && return 1
	for i in $(seq 0 60); do
		[ "X$(get_attr $ID STAT)" = "Xrunn" ] && return 0
		sleep 2
	done
	return 1
}

ping_in() {
	IP=$(get_attr $ID IP)
	sleep 8  # give it time to initialize the network
	ping6 -q -c1 $IP || sleep 10  # give it more time if needed :D
	ping6 -q -c3 $IP
	ping6 -q -c3 -s10000 $IP
}

ssh_here() {
	ssh -i "$SSHKEY" -o StrictHostKeychecking=no -o UserKnownHostsFile=/dev/null root@$IP $@
}

ssh_in() {
	ssh_here 'echo hello'
}

ping_out() {
	ssh_here 'ping6 -q -c3 google.ch'
}

http_out() {
	ssh_here 'wget -q www.google.ch' >/dev/null
}

cleanup() {
	onevm terminate $ID || onevm recover --delete $ID
	for i in $(seq 0 60); do
		onevm list | grep $ID >/dev/null || return 0  # wait till it disappears
		sleep 2
	done
	return 1
}

fail_on_purpose() {
	return 1
}

###################

fail() {
	echo "${METRIC}_completed_time{state=\"fail\", stage=\"$1\"} $(date +%s)" >> "$F"
	echo "${METRIC}_up{failed_stage=\"$1\"} 0" >> "$F"
	mv "$F" "$STATS_FILE"
	echo "FAIL" >&2
	exit 47
}

main() {
	stage_counter=0
	for stage in $STAGES; do
		stage_counter=$(($stage_counter+1))
		echo " ======= $stage_counter-$stage =======" >&2
		s=$(date +%s)
		$stage || fail $stage
		e=$(date +%s)
		echo "${METRIC}_duration_seconds{stage=\"${stage_counter}-${stage}\",state=\"success\"} $(($e-$s))" >> "$F"
	done
	echo "${METRIC}_completed_time{state=\"success\"} $(date +%s)" >> "$F"
	echo "${METRIC}_up 1" >> "$F"
	mv "$F" "$STATS_FILE"
	echo SUCCESS >&2
}

main
