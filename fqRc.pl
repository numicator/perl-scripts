#!/usr/bin/perl -w
###############################################################################
#
#           reverse complement fastq file
#           eg. coverts outies, MP into innies, PE
#
###############################################################################

use warnings;
use strict;

my $cnt;
while(<>)
{
	$cnt++;
	my($id, $id2, $seq, $qual);
	if(/^@/)
	{
		$id   = $_;
		$seq  = <>;
		$id2  = <>;
		$qual = <>;
	}
	else
	{
		print STDERR "should not be here!\n";
		exit;
	}
	chomp $seq; chomp $qual;
	$seq  =~ tr/ACGT/TGCA/;
	$seq  =~ tr/acgt/tgca/;
	$seq  = reverse($seq);
	$qual = reverse($qual);
	print "$id$seq\n$id2$qual\n";
}
print STDERR "prcessed $cnt sequences\nDONE.\n";
