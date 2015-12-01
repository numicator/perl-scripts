#!/usr/bin/perl -w
###############################################################################
#
#           subsamples fasta file
#
###############################################################################
use strict;
use List::Util 'shuffle';

my $cnt = 0;
my @a;
my @inx;

my $fname = $ARGV[0];
my $n     = $ARGV[1];

print STDERR "taking $n random sequences from fasta file $fname.\n";
open F, "$fname" or die "ERROR: Could not open file $fname\n";

my($id, $seq);
while(<F>)
{
	if(/(>.*)/)
	{
		push @a, [$id, $seq] if(defined $id);
		push @inx, $cnt++;
		$id  = $1;
		$seq = '';
	}
	else
	{
		$seq .= $_;
	}
}
if(defined $id)
{
	push @a, [$id, $seq];
	push @inx, $cnt++;
}
@inx = shuffle @inx;

for(my $i = 0; $i < $n; $i++)
{
	print "$a[$inx[$i]][0]\n$a[$inx[$i]][1]";
}
print STDERR "Processed ".(scalar @a)." sequences.\nDone.\n";
