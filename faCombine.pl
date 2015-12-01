#!/usr/bin/perl -w
###############################################################################
#
#         combines fasta file given as args and prints one fasta with uniq ids
#
###############################################################################
use warnings;
use strict;
use Getopt::Std;
use BioInfo;

my $cnt = 0;
print STDERR "".(scalar(@ARGV))." files to go:\n";
foreach my $fname(@ARGV)
{
	print STDERR "reading from file $fname\n";
	open F, $fname || die "ERROR: Couldn't open file $fname\n";
	my $cnx = 0;
	while(<F>)
	{
		if(/^>(.*)/)
		{
			$cnt++;
			$cnx++;
			#print ">lcl|$cnt $1\n";
			print ">tethya01_$cnt\n";
		}
		else
		{
			print $_;
		}
	}
	close F;
	print STDERR "read $cnx sequences\n";
}
print STDERR "printd total of $cnt sequences\nDONE.\n";
