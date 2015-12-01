#!/usr/bin/perl -w
###############################################################################
#
#           reverses order in sequences in FASTA file
#
###############################################################################
use strict;

my $cnt = 0;
my @a;
my @ar;

print STDERR "Reversing fasta file.\n";
my($id, $seq);
while(<>)
{
	if(/(>.*)/)
	{
		push @a, [$id, $seq] if(defined $id);
		$id  = $1;
		$seq = '';
	}
	else
	{
		$seq .= $_;
	}
}
push @a, [$id, $seq] if(defined $id);
@ar = reverse @a;

foreach(@ar)
{
	print "$_->[0]\n$_->[1]";
}
print STDERR "Processed ".(scalar @ar)." sequences.\nDone.\n";
