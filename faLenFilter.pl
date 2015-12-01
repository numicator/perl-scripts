#!/usr/bin/perl -w
###############################################################################
#
#         filters fasta file and prints only sequences longer than the -l param
#         either counts Ns or not
#         reads from STDIN
#
###############################################################################
use warnings;
use strict;
use Getopt::Std;
use BioInfo;

my %opt;
getopts('nl:', \%opt) or die "Error at getopts.\n";
my $nNo    = defined $opt{n}? 1: 0;
my $lenMin = $opt{l};

my $id;
my $len;
my $seq;
my $cnt;
my $cnx;

if(!$lenMin)
{
	print STDERR "need the -l param with minimum length of the sequence.\nthe -n param may be usefull too\n";
	exit 1;
}

print STDERR "not countig sequences shorter than $lenMin bases\n";
print STDERR "not countig Ns\n" if($nNo);
$len = 0;
while(<>) 
{
	if(/^>(.+)/) 
	{
		$cnt++;
		if(defined $id && $len >= $lenMin) 
		{
			$cnx++;
			print ">$id\n".formatFaSeq($seq, 80);
		}
		$id = $1;
		$seq = '';
		$len = 0;
	}
	else 
	{
		chomp;
		$seq .= $_;
		s/n//gi if($nNo);
		$len += length($_);
	}
}

if(defined $id && $len >= $lenMin) 
{
	$cnx++;
	print ">$id\n".formatFaSeq($seq, 80);
}
print STDERR "processed $cnt, printed $cnx sequences\n";
print STDERR "DONE.\n";