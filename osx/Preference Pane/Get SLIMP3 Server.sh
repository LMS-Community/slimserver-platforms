#! /bin/sh
echo `ps -axww | grep "slimp3\.pl\|slimp3d" | grep -v grep | cat`
