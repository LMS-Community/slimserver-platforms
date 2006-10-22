#! /bin/sh

echo `ps -axww | grep "slimserver\.pl" | grep -v grep | cat`
