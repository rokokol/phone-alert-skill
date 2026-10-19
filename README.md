<div align="center">

# Phone alert skill

**An agent that needs you while you are away from the screen**

[![Agent Skill](https://img.shields.io/badge/Agent_Skill-6E56CF?style=flat)](https://agentskills.io)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat&logo=gnubash&logoColor=white)
![Termux](https://img.shields.io/badge/Termux-000000?style=flat&logo=android&logoColor=white)
[![license](https://img.shields.io/badge/MIT-3DA639?style=flat)](LICENSE)
[![ci](https://github.com/rokokol/phone-alert-skill/actions/workflows/build.yml/badge.svg)](https://github.com/rokokol/phone-alert-skill/actions/workflows/build.yml)

</div>

Lets an agent call you to your Android phone when a long job ends, a decision blocks it, or it needs a password. The phone vibrates long-short-long, which is Morse K, "over to you", and is easy to tell from a call or a message through a pocket. A notification with sound carries the reason, and the torch lights for a phone that lies face down on a desk. For a set time, the agent puts an alarm in the phone's clock app instead

The script is sent to the phone over ssh on each call, so the phone holds no copy that can go stale

## Requirements

- An Android phone with [Termux](https://termux.dev), the [Termux:API](https://wiki.termux.com/wiki/Termux:API) app and the `termux-api` package, and permission for the torch
- An ssh host for the phone that the agent can reach, named in the agent's instructions or memory

## Install

Clone the repository into the skills directory of your agent, for example:

```sh
git clone https://github.com/rokokol/phone-alert-skill ~/.claude/skills/phone-alert
```

## Usage

Ask the agent to call you when something happens: "позови меня, когда сборка закончится", "buzz my phone if the tests fail". The agent runs `alert.sh ring` with the reason; `alert.sh help` is the reference

To try it by hand:

```sh
ssh PHONE "bash -s -- ring $(printf '%q ' 'The build is done')" < alert.sh
```

## Development

`nix develop -c ./tests/check.sh` is the whole gate, the same in CI: it lints the scripts and workflows, holds the docs to the house rules, and runs `tests/alert.sh`, which puts stubs of the termux-api commands on `PATH` and checks the order of the calls and the exit codes. How the signal feels in a pocket is checked only on a phone
