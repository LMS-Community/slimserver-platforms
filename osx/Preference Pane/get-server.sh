#! /bin/sh
echo `ps -axww | grep "ueml\.pl" | grep -v grep | cat`
