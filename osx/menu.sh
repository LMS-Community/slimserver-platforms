#!/bin/bash

if [ -x ./bin/perl ]; then
	echo "Own Perl"
	./bin/perl -I. LMSMenu.pl $@
elif [ -x ../per/bin/perl ]; then
	# echo "Parent's Perl"
	../perl/bin/perl -I. LMSMenu.pl $@
else
	echo "System Perl!"
	perl -I. ./LMSMenu.pl $@
fi
