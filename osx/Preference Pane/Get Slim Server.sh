#! /bin/sh
echo `ps -axww | grep "slimp3\.pl\|slimp3d\|slimpserver\.pl\|slimd" | grep -v grep | cat`
