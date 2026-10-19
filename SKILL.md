---
name: phone-alert
description: "Call a person to their Android phone: now, with a long-short-long vibration, the torch and a notification with sound that says why, or at a set time, with an alarm in the phone's clock app. Use when work needs the user while they are away from the screen, or they ask to be called or woken at a time. Triggers: ping me, call me when it is done, buzz my phone, set an alarm, wake me at, позови меня, дай знать на телефон, позвони когда закончишь, вибрани, пни меня, поставь будильник, разбуди меня в"
license: MIT
---

# phone-alert

[`alert.sh`](alert.sh) runs in Termux on the phone and needs the termux-api package and the Termux:API app there. It is sent rather than installed, so the copy beside this file is the only one; `PHONE` is the phone's ssh host from the agent's instructions (CLAUDE.md, AGENTS.md…) or the harness's memory. `alert.sh help` is the reference

```sh
ssh PHONE "bash -s -- ring $(printf '%q ' -t TITLE "MESSAGE")" < alert.sh
```

- **Quote the arguments with `printf '%q '`**: ssh joins its arguments into one line that the phone's shell splits again, so an unquoted message of several words arrives as several arguments and the script refuses it
- **MESSAGE says why, in the user's language, in one line they can act on**: what finished, what is blocked, what is needed. The vibration only says "look"; the notification is what they read. Set the title in their language with `-t`
- **The alert plays once and says nothing about whether it was seen.** When the answer matters, wait for the user to reply through the conversation rather than calling again in a loop
- **Call once per event, not per step.** A phone that buzzes for every finished command teaches its owner to ignore it

## At a set time: an alarm

An alarm goes to the phone's clock app through Android's `SET_ALARM` intent; termux-api has no alarm call. `CLOCK` is the clock app's package from the agent's instructions or memory, or from the user, since a Termux shell cannot list who handles the intent

```sh
ssh PHONE "am start -a android.intent.action.SET_ALARM -p CLOCK --ei android.intent.extra.alarm.HOUR H --ei android.intent.extra.alarm.MINUTES M $(printf '%q ' --es android.intent.extra.alarm.MESSAGE "MESSAGE") --ez android.intent.extra.alarm.SKIP_UI true </dev/null"
```

- **Termux needs the special access "Display over other apps"**: the intent starts an activity, and Android drops an activity start from the background without an error unless Termux has that access or a window on the screen
- **Name the package with `-p`, never an activity with `-n`**: the class that handles the intent may not be exported, and an explicit start of it fails with a `SecurityException`
- **`Starting:` is printed whether or not the alarm was set**, so tell the user the time you set and let them confirm it in the clock
