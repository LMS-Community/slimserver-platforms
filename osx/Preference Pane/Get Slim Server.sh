#! /bin/sh
echo `ps -axww | grep "slimpserver\.pl\|slimserver|squeezecenter\.pl\|squeezecenter" | grep -v grep | cat`
