#!/usr/bin/perl -w
###############################################################################
#
#           splits FASTA file into several files containing no more then n
#           sections
#
###############################################################################
use strict;
use List::Util 'shuffle';

my $inname = $ARGV[0];
my $seg    = $ARGV[1];
my $ndig   = $ARGV[2]? $ARGV[2]: 3;
my $rnd		 = $ARGV[3];
my $cnt    = 0;
my $outname;

print STDERR "Splitting fasta file.\n";
if(scalar @ARGV < 2)
{
	print "usage faSplit.pl <input file> <number of sections per file> [<number of digits in the section - def. 3>] [<random order? - def 0>]]\n";
	print "  eg: faSplit.pl tosplit.fa 100 4 will produce files:\n";
	print "  tosplit.fa.0001, tosplit.fa.0002... each of max. 100 sections.\n";
	exit;
}

open INFILE, "<$inname";
if($rnd)
{
	processRnd();
}
else
{
	process();
}
close INFILE;
print STDERR "Done.\n";

sub process
{
	while(<INFILE>)
	{
		if(/>.*/)						#fasta section header
		{
			if($cnt % $seg == 0)
			{
				close OUTFILE if($cnt == 0);
				$outname = $inname ."." . sprintf("%0".$ndig."d", ($cnt / $seg) + 1);
				print STDERR "out file: $outname...\n";
				open OUTFILE, ">$outname";
			}
			$cnt++;
			print OUTFILE $_;
		}
		else
		{
			print OUTFILE $_;
		}
	}

	close OUTFILE if($cnt != 0);
}#process

sub processRnd
{
	print STDERR "Random order of sequences\n";
	my %h;
	my @a;
	
	my($id, $seq);
	while(<INFILE>)
	{
		if(/(>.*)/)
		{
			$h{$id} = $seq if(defined $id);
			$id = $1;
			$seq = '';
		}
		else
		{
			$seq .= $_;
		}
	}
	$h{$id} = $seq if(defined $id);
	@a = shuffle keys %h;
	foreach(@a)
	{
		if($cnt % $seg == 0)
		{
			close OUTFILE if($cnt == 0);
			$outname = $inname ."." . sprintf("%0".$ndig."d", ($cnt / $seg) + 1);
			print STDERR "out file: $outname...\n";
			open OUTFILE, ">$outname";
		}
		$cnt++;
		print OUTFILE "$_\n$h{$_}";
	}
	close OUTFILE if($cnt != 0);
}#processRnd
