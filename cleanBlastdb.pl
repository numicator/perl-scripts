#!/usr/bin/perl -w
###############################################################################
#
#         cleans deflines of NCBI blast databases in fasta format
#
###############################################################################
use warnings;
use strict;
use Getopt::Std;
use BioInfo;

my $cnt = 0;
my $cnx = 0;
while(<>)
{
	if(/^>([^>]*)/)
	{
		$cnt++;
		my $def = $1;
		$def =~ s/\s+$//;
		print ">$def\n";
	}
	else
	{
		print $_;
	}
}
print STDERR "printd total of $cnt sequences\nDONE.\n";