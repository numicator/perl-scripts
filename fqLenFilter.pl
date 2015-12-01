#!/usr/bin/perl -w
###############################################################################
#
#           subsamples FASTQ file pair
#
###############################################################################
use strict;

my $inname1  = $ARGV[0];
my $inname2  = $ARGV[1];
my $outname1 = $ARGV[2];
my $outname2 = $ARGV[3];
my $lenMin   = $ARGV[4];
my $cnt      = 0;
my $cnx      = 0;

if(scalar @ARGV < 2)
{
	print "usage fqSubsample.pl <input file.1> <input file.2> <out file.1> <out file.2> <min length of the read>\n";
	exit;
}
print STDERR "Length filtering fastq file pair $inname1 $inname2 using length cutoff $lenMin\n";

open IN1, "<$inname1";
open IN2, "<$inname2";
open O1, ">$outname1";
open O2, ">$outname2";
while(<IN1>)
{
	$cnt++;
	my($id1, $id12, $seq1, $qual1);
	my($id2, $id22, $seq2, $qual2);
	if(/^@/)
	{
		$id1   = $_;
		$seq1  = <IN1>;
		$id12  = <IN1>;
		$qual1 = <IN1>;

		$id2   = <IN2>;
		$seq2  = <IN2>;
		$id22  = <IN2>;
		$qual2 = <IN2>;
		
		my $i1 = $id1;
		my $i2 = $id2;
		chomp $i1;
		chomp $i2;
		die "ERROR @ section $cnt: sequece ids: $id1 and $id2 are not the same\n" if(substr($i1, 0, -2) ne substr($i1, 0, -2));
	}
	else
	{
		print STDERR "should not be here!\n";
		exit;
	}
	if((length($seq1) >= $lenMin + 1) && (length($seq2) >= $lenMin + 1))
	{
			$cnx++;
			print O1 "$id1$seq1$id12$qual1";
			print O2 "$id2$seq2$id22$qual2";
	}
}
close IN1;
close IN2;
close O1;
close O2;
print STDERR "processed $cnt, printed $cnx read pairs\nDone.\n";