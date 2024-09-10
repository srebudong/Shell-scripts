#!/bin/bash

function check_deps() {
    if ! rpm -qa | grep -q '^expect'; then
        echo "[INFO] Installing necessary tools"
        yum install expect -y >/dev/null 2>&1
    fi
    echo "[INFO] Necessary tools installed"
}

function add_ssh_key() {
    expect <<EOF
spawn ssh-keygen -t rsa
expect {
    ".ssh/id_rsa" {
        send "\r"
        exp_continue
    }
    "Enter file in which to save the key" {
        send "\r"
        exp_continue
    }
    "Overwrite (y/n)?" {
        send "n\r"
        exp_continue
    }
    "Enter passphrase (empty for no passphrase)" {
        send "\r"
        exp_continue
    }
    "Enter same passphrase again" {
        send "\r"
        exp_continue
    }
    timeout {
        puts "Timed out waiting for expected prompt."
        exit 1
    }
}
EOF
}

function dispense_key() {
    local passwd=$1
    shift
    for host in "$@"; do
        expect <<EOF
spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@$host
expect {
    "Are you sure you want to continue connecting" {
        send "yes\r"
        exp_continue
    }
    "root@$host's password:" {
        send -- "${passwd}\r"
        exp_continue
    }
    timeout {
        puts "Timed out waiting for expected prompt."
        exit 1
    }
}
EOF
    done
}

function main() {
    local passwd=123
    check_deps
    add_ssh_key
    dispense_key "${passwd}" "$@"
}

main "$@"
