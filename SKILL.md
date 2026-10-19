---
name: phone-alert
description: "Call a person to their Android phone once: a long-short-long vibration felt through a pocket, the torch, and a notification with sound that says why. Use when work needs the user while they are away from the screen: a long job finished or failed, a decision blocks the next step, an approval or a password is needed, or they asked to be called when something happens. Triggers: ping me, call me when it is done, let me know on my phone, buzz my phone, get my attention, позови меня, дай знать на телефон, позвони когда закончишь, вибрани, пни меня, сообщи когда доделаешь, привлеки внимание"
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
