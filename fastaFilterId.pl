#!/usr/bin/perl -w
#filters sequences from fasta file with identifiers from a tsv file
#ids need to be in the first column, or in the column specified as the third param (1-based) or in the only column
#lines started with '#' are comments

use warnings;
use strict;

my $cnt = 0;
my %ToRemove;
my $col = $ARGV[2]? $ARGV[2]: 1;

print STDERR "loading id file $ARGV[0], column $col\n";
open F, "<$ARGV[0]" or die "couldn't open $ARGV[0]\n";
while(<F>)
{
	chomp;
	next if($_ eq '' || /^#/);
	$cnt++;
	my @a = split "\t";
	$ToRemove{$a[$col - 1]} = 1;
	#print STDERR "\"$a[$col - 1]\"\n";
}
print STDERR "loaded $cnt lines from id file, recorded ".(scalar keys %ToRemove)." ids to remove\n";
close F;

print STDERR "loading fasta file $ARGV[1]\n";
open F, "<$ARGV[1]" or die "couldn't open $ARGV[1]\n";
$cnt = 0;
my $cnx = 0;
my $remove = 0;
while(<F>)
{
	if(/^>([\w\.]+)/)
	#if(/^>gi\|(\d+)/)
	{
		#print STDERR "\"$1\"";
		$remove = defined $ToRemove{$1}? 1: 0;
		$cnt++;
		$cnx++ if($remove);
	}
	#elsif(/^>(\S+)/)
	#{
	#	print STDERR "WARNING: unknown format of defline '$_'; skipping \n";
	#	$remove = 0;
	#}
	print $_ if($remove);
}
print STDERR "loaded $cnt, printed $cnx sequences\n";
close F;
