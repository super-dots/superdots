#!/usr/bin/env bash


THIS_PROG="$0"

function sd::ux::confirm {
    msg="${1:-"Are you sure?"}"
    msg="${msg} (y/n) "
    sd::log::inline "$msg"
    read answer
    ! [ "$answer" == "${answer#[Yy]}" ]
}
