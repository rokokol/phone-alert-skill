#!/usr/bin/env bash
# Behaviour tests for alert.sh, run on any host: the termux-api commands are stubs on PATH that log their calls
# Needs bash 3.2 and POSIX tools only
set -euo pipefail

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ALERT="$HERE/../alert.sh"
work=$(mktemp -d "${TMPDIR:-/tmp}/phone-alert-test.XXXXXX")
trap 'rm -rf "$work"' EXIT

mkdir "$work/bin"
for cmd in termux-vibrate termux-notification; do
  cat >"$work/bin/$cmd" <<EOF
#!/usr/bin/env bash
printf '%s %s\n' "$cmd" "\$*" >>"\$STUB_LOG"
EOF
done
# The torch answers late, the way every termux-api call does, so a call that overlaps it logs first
cat >"$work/bin/termux-torch" <<'EOF'
#!/usr/bin/env bash
sleep 0.3
printf 'termux-torch %s\n' "$*" >>"$STUB_LOG"
EOF
chmod +x "$work/bin/"*

failures=0
check() { # NAME CONDITION...
  local name="$1"
  shift
  if "$@"; then
    printf 'ok   %s\n' "$name"
  else
    printf 'FAIL %s\n' "$name" >&2
    failures=$((failures + 1))
  fi
}

# Runs alert.sh with the stubs; sets $status and $log
run() {
  : >"$work/log"
  status=0
  STUB_LOG="$work/log" PATH="$work/bin:$PATH" bash "$ALERT" "$@" >"$work/out" 2>"$work/err" || status=$?
  log="$work/log"
}
sequence() { cut -d' ' -f1-2 "$log" | tr '\n' ' '; }

run ring "hello"
check "a ring exits 0" [ "$status" = 0 ]
check "the notification carries the message and sounds" grep -q -- '^termux-notification .*-c hello .*--sound' "$log"
check "the torch is lit for the whole pulse group and nothing overlaps it" \
  [ "$(sequence)" = "termux-notification -i termux-torch on termux-vibrate -f termux-vibrate -f termux-vibrate -f termux-torch off " ]
check "the pulses are long, short, long" \
  [ "$(grep '^termux-vibrate' "$log" | sed 's/.*-d //' | tr '\n' ' ')" = "1000 250 1000 " ]

run ring -t "Look" "hello"
check "-t sets the title" grep -q -- '-t Look' "$log"

# The way it reaches a phone: the script itself is bash's stdin
: >"$work/log"
status=0
STUB_LOG="$work/log" PATH="$work/bin:$PATH" bash -s -- ring "hello" <"$ALERT" >/dev/null 2>&1 || status=$?
log="$work/log"
check "under bash -s the whole script runs" [ "$status" = 0 ]
check "under bash -s all three pulses play" [ "$(grep -c '^termux-vibrate' "$log")" = 3 ]

for bad in "ring" "ring hi there" "ring --bogus hi" "ring -t" "nope"; do
  # shellcheck disable=SC2086 # each case is a word list on purpose
  run $bad
  check "usage error exits 2: $bad" [ "$status" = 2 ]
done

run --help
check "--help exits 0 and names the ring subcommand" grep -q 'alert.sh ring' "$work/out"

if ((failures)); then
  printf 'check.sh: %d failed\n' "$failures" >&2
  exit 1
fi
printf 'check.sh: everything holds\n'
