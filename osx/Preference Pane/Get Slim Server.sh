#! /bin/sh
echo `ps -axww | grep "slimp3\.pl\|slimp3d\|slimpserver\.pl\|slimserver" | grep -v grep | cat`
