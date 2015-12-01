#!/usr/bin/perl -w

################################################################################
#
#
################################################################################

use strict;
use warnings;

$| = 1;

my $fname  = $ARGV[0];
my $number = $ARGV[1];

my %Rnd;
my $fsize;

my $ln = `fastacmd -d db/$fname -I|grep "sequences;"`;
$ln =~ /^\s*([\d,]+)\s/;
$fsize = $1;
$fsize =~ s/,//g;
print STDERR "getting $number of random sequences from $fname containing $fsize sequences\n";

do
{
	$Rnd{int(rand($fsize)) + 1} = 1;
}while((scalar keys %Rnd) < $number);

$ln = '';
foreach(keys %Rnd)
{
	$ln .= ',' if($ln ne '');
	$ln .= "lcl|$_";
}
my $ln = `fastacmd -d db/$fname -s \"$ln\"`;
print "$ln\n";

print STDERR "DONE.\n";