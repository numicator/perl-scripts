#!/usr/bin/perl -w
###############################################################################
#                                                                             #
#                                                                             #
###############################################################################

use strict;

use Getopt::Std;
use BioInfo;

my %opt;
getopts('b:l:d:cr:q', \%opt) or die "Error at getopts.\n";

my $baseBeg = $opt{b};
my $baseLen = $opt{l};
my $dropLen = $opt{d};
my $convert = $opt{c}; #convert from Illumina 1.9 to Illumina 1.5 headers and quality encoding
my $renid   = $opt{r}; #rename sequece ids to <prefix>_<serialnumber>_<suffix>; the param should be: "prefix:suffix"
my $qlist   = $opt{q}; #just check the quality encoding

$baseBeg = 1    if(!defined $baseBeg);
$baseLen = 1024 if(!defined $baseLen);

my($renp, $rens);
if(defined $renid)
{
	if($renid =~ /^(.+?):(.+)/)
	{
		$renp = $1;
		$rens = $2;
	}
	else
	{
		print STDERR "ERROR: format of the id rename parameter is wrong. It should be 'prefix:suffix\n";
		exit;
	}
}

if(!defined $qlist)
{
	print STDERR "bases starting from $baseBeg, length of the sequence is $baseLen, drop length is ".(defined $dropLen? "$dropLen,": "not specified,")." :conversion phred+33 -> phred+64: ".(defined $convert? 'yes': 'no').", rename ".(defined $renid? 'yes': 'no')."\n";
}
else
{
	print STDERR "just checking quality coding range using first 100k sequences\n";
}

my($qmin, $qmax);
my $cnt = 0;
my $cnx = 0;

while(<>)
{
	$cnt++;
	my($id, $id2, $seq, $qual);
	if(/^@/)
	{
		$id = $_;
		$seq = <>;
		$id2 = <>;
		$qual = <>;
		chomp $id; chomp $seq; chomp $id2; chomp $qual;
	}
	else
	{
		die "ERROR: this doesn't look like fastq format!\n";
	}
	if(!defined $qlist)
	{
		$seq  = substr($seq, $baseBeg - 1, $baseLen);
		$qual = substr($qual, $baseBeg - 1, $baseLen);
		next if(defined $dropLen && length($seq) < $dropLen);
		$cnx++;
		
		if(defined $convert)
		{
			$id =~ s/\s+(\d)\S+$/#CGCAAA\/$1/ if(!defined $renid);
			$qual =~ tr/\041-\137/\100-\176/;
		}
		
		
		
		$id  = '@'.$renp.'_'.$cnt.$rens if(defined $renid);
		$id2 = '+';
		print "$id\n$seq\n$id2\n$qual\n";
	}
	else
	{
		my($a, $b) = qualityRange($qual);
		$qmin = $a if(!defined $qmin || $qmin > $a);
		$qmax = $b if(!defined $qmax || $qmax < $a);
		last if($cnt >= 100000);

	}
}
if(defined $qlist)
{
	print STDERR "quality range: $qmin - $qmax\n";
	if($qmin < 59)
	{
		print STDERR "encoding looks like phred+33 (sanger or Illumina 1.8 and above)\n";
		print "33";
	}
	elsif($qmax > 73)
	{
		print STDERR "encoding looks like phred+64 (Illumina 1.3 up to, but not including 1.8 nor sanger)\n";
		print "64";
	}
	else
	{
		print STDERR "can not identify the encoding\n";
		print "NA";
	}
}
print STDERR "processed $cnt, printed $cnx\nDONE\n";
exit 0;

sub qualityConvert #not in use anymore
{
	my($s) = shift @_;
	my $l = length($s);
	my $val;
	my $cqual = '';
	for(my $i = 0; $i < $l; $i++)
	{
		$val = 31 + ord(substr($s, $i, 1)); #illumina 1.9 to 1.5
		$cqual .= chr($val);
	}
	return $cqual;
}#qualityConvert

sub qualityRange
{
	my($s) = shift @_;
	my($a, $b);
	my $l = length($s);
	my $v;
	for(my $i = 0; $i < $l; $i++)
	{
		$v = ord(substr($s, $i, 1));
		$a = $v if(!defined $a || $a > $v);
		$b = $v if(!defined $b || $b < $v);
	}
	return($a, $b);
}#qualityRange
