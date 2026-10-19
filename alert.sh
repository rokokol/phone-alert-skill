#!/usr/bin/env bash
# Needs bash 3.2 and POSIX tools only, plus termux-notification, termux-torch and termux-vibrate
# from the termux-api package at run time
# The pulse timings are measured on a phone in a pocket: termux-vibrate returns about 1.5 s after the call
# whatever the duration, so pulses are started in the background on a schedule rather than one after another.
# Nothing else runs during the pulses: the app serves calls one at a time, a delayed pulse is cut short
# by the next one, and two pulses are felt as one
set -euo pipefail

usage() {
  cat <<'EOF'
alert.sh — call a person to their Android phone once: a notification with sound, the torch, and a
long-short-long vibration

  alert.sh ring [-t TITLE] MESSAGE

  -t TITLE      the notification title (default: Attention)

Run it in Termux on the phone, or send it there; ssh joins its arguments into one line that the
phone's shell splits again, so quote them for that shell:
  ssh PHONE "bash -s -- ring $(printf '%q ' -t TITLE "MESSAGE")" < alert.sh
Needs the termux-api package and the Termux:API app; vibration ignores silent mode, the sound
follows the notification volume and is never changed here
Exit 0 done, 2 on a usage error
EOF
}

die() { # the request itself is wrong
  printf 'alert.sh: %s\n' "$1" >&2
  exit 2
}

cmd_ring() {
  local title="Attention"
  while (($#)); do
    case "$1" in
      -t)
        (($# >= 2)) || die "-t needs a title"
        title="$2"
        shift 2
        ;;
      --) shift && break ;;
      -*) die "no such flag: $1" ;;
      *) break ;;
    esac
  done
  (($# == 1)) || die "ring needs exactly one MESSAGE"

  # A new alert replaces the previous one rather than piling up
  termux-notification -i phone-alert -t "$title" -c "$1" --priority max --sound
  termux-torch on
  # An interrupted run must not leave the torch burning
  trap 'termux-torch off || true' EXIT
  termux-vibrate -f -d 1000 &
  sleep 1.55
  termux-vibrate -f -d 250 &
  sleep 1.05
  termux-vibrate -f -d 1000 &
  wait
}

cmd="${1:-}"
(($# == 0)) || shift
case "$cmd" in
  ring) cmd_ring "$@" ;;
  -h | --help | help) usage ;;
  '')
    usage >&2
    exit 2
    ;;
  *)
    printf 'alert.sh: no such subcommand: %s\n\n' "$cmd" >&2
    usage >&2
    exit 2
    ;;
esac
