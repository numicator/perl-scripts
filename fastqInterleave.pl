#!/usr/bin/perl -w
###############################################################################
#                                                                             #
# takes two mate fastq files and makes one interleaved fastq file             #
# (each mate pair is consecutive in the output file)                          #
#                                                                             #
###############################################################################

open A, "<$ARGV[0]" or die "couldn't open fastq file $ARGV[0]\n";
open B, "<$ARGV[1]" or die "couldn't open fastq file $ARGV[1]\n";

my $a;
while(<A>)
{
	$a = $_; print $a;
	$a = <A>; print $a;
	$a = <A>; print $a;
	$a = <A>; print $a;
	$a = <B>; print $a;
	$a = <B>; print $a;
	$a = <B>; print $a;
	$a = <B>; print $a;
}
close A;
close B;
print STDERR "DONE.\n";
