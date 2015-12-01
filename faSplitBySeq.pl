#!/usr/bin/perl -w
###############################################################################
#
#           splits FASTA file into several files containing one sequence each
#
###############################################################################
use strict;

my $inname = $ARGV[0];
my $outname;

print STDERR "Splitting fasta file.\n";
if(scalar @ARGV < 1)
{
	print "usage faSplit.pl <input file>\n";
	exit;
}

open INFILE, "<$inname";
process();
close INFILE;
print STDERR "Done.\n";

my $id;
sub process
{
	while(<INFILE>)
	{
		if(/>(\S+)/)
		{
			close OUTFILE if(defined $id);
			$id = $1;
			$id =~ s/\|//g;
			$outname = "$id.fa";
			print STDERR "out file: $outname...\n";
			open OUTFILE, ">$outname";
			print OUTFILE $_;
		}
		else
		{
			print OUTFILE $_;
		}
	}
	close OUTFILE if(defined $id);
}#process
