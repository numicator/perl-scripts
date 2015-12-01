#!/usr/bin/perl -w
###############################################################################
#
#           basic statistics of fasta file: n50, length and so on
#           reads from STDIN
#
###############################################################################
use warnings;
use strict;
use Getopt::Std;

my %opt;
getopts('nl:', \%opt) or die "Error at getopts.\n";
my $nNo    = defined $opt{n}? 1: 0;
my $lenMin = defined $opt{l}? $opt{l}: 0;

print STDERR "not countig sequences shorter than $lenMin\n" if($lenMin);
print STDERR "not countig Ns\n" if($nNo);

foreach my $fname(@ARGV)
{
	#print STDERR "$fname:\n";
	if(!open(F, $fname))
	{
		print STDERR "couldn't open $fname\n";
		next;
	}
	my @arr;
	my $len;
	my $id;
	my $seq;

	my($cnt, $total, $longest, $shortest, $n25, $n50, $n75);

	$len = 0;
	while(<F>) 
	{
		if(/^>(\w+)/) 
		{
			if(defined $id && $len >= $lenMin) 
			{
				$total += $len;
				push(@arr, $len);
			}
			$id = $1;
			$len = 0;
		}
		else 
		{
			chomp;
			s/n//gi if($nNo);
			$len += length($_);
		}
	}
	close F;

	if(defined $id && $len >= $lenMin) 
	{
		$total += $len;
		push(@arr, $len);
	}

	my @arrs = sort {$b <=> $a} @arr;
	my($n25v, $n50v, $n75v, $avg, $n50n) = (0, 0, 0, 0, 0);
	foreach my $val(@arrs)
	{
		$avg += $val;

		if($n50v < $total * 0.50)
		{
			$n50v += $val;
			$n50   = $val;
			$n50n++;
		}
		if($n25v < $total * 0.25)
		{
			$n25v += $val;
			$n25   = $val;
		}
		if($n75v < $total * 0.75)
		{
			$n75v += $val;
			$n75   = $val;
		}
	}

	$longest  = $arrs[0];
	$shortest = $arrs[$#arrs];
	$cnt = scalar @arrs;
	$avg = sprintf("%.0f", $avg / $cnt);
	$cnt =~ s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g;
	$n25 =~ s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g;
	$n50 =~ s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g;
	$n75 =~ s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g;
	$total =~ s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g;
	$longest =~ s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g;
	$shortest =~ s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g;
	$avg =~ s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g;
	print "count=$cnt avg=$avg n25=$n25 n50=$n50 ($n50n) n75=$n75 longest=$longest shortest=$shortest size=$total [$fname]\n";
}