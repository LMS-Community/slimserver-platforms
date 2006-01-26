#! /bin/sh
echo `ps -axww | grep "slimpserver\.pl\|slimserver" | grep -v grep | cat`
