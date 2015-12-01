#!/usr/bin/perl -w
###############################################################################
#
#           filters paired FASTQ or FASTA files takes ids from:
#            - tsv
#            - fastq
#            - sam
#
###############################################################################
use strict;
use warnings;

if(scalar @ARGV < 2)
{
	print "usage fqSubsample.pl <id file> <input file.1> <input file.2> <out file.1> <out file.2> <1 - keep; 0 - remove> <fasta|fastq>\n";
	exit;
}

my $idname   = $ARGV[0];
my $inname1  = $ARGV[1];
my $inname2  = $ARGV[2];
my $outname1 = $ARGV[3];
my $outname2 = $ARGV[4];
my $keep     = $ARGV[5];
my $fast     = $ARGV[6];
my $cnt      = 0;
my $fq       = 0;
my %inx;

die "need format to be fasta or fastq\n" if($fast ne 'fasta' && $fast ne 'fastq');

print STDERR "loading id file $idname\n";
open ID, "<$idname" or die "ERROR: couldn't open $idname\n";
while(<ID>)
{
	chomp;
	/^(\S+)/;
	next if(!$1 || $1 eq '@SQ'); #skip header in sam files
	
	my $l = $1;
	
	$cnt++;
	if($cnt == 1 && substr($l, 0, 1) eq '@')
	{
		s/^@//;
		$l =~ s/^@//;
		print STDERR "fastq format detected\n";
		$fq = 1;
		print STDERR "will be stripping runs '/1', '/2' suffixes\n" if(/\/[12]$/);
	}
	
	if(/\/[12]$/)
	{
		$inx{substr($_, 0, -2)} = 1;
		#print STDERR "".(substr($l, 0, -2))."\n";
	}
	else
	{
		$inx{$l} = 1;
		#print STDERR "$l\n";
	}
	
	#print STDERR substr($l, 0, -2)."\n";
	if($fq)
	{
		<ID>;
		<ID>;
		<ID>;
	}
}
close ID;
print STDERR "recorded ".(scalar keys %inx). " ids\n";

#foreach(keys %inx){print STDERR "$_\n"}; #die;

print STDERR "filtering ".($fast eq 'fasta'? 'fasta': 'fastq')." file pair $inname1 $inname2, sequences with matching ids will be ".($keep? "saved": "excluded")."\n";
open IN1, "<$inname1" or die "ERROR: couldn't open $inname1\n";
open IN2, "<$inname2" or die "ERROR: couldn't open $inname2\n";
open O1, ">$outname1" or die "ERROR: couldn't open $outname1 for writing\n";
open O2, ">$outname2" or die "ERROR: couldn't open $outname2 for writing\n";
$cnt = 0;
my $cnx = 0;
while(<IN1>)
{
	$cnt++;
	my($id1, $id12, $seq1, $qual1);
	my($id2, $id22, $seq2, $qual2);
	if($fast eq 'fastq')
	{
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
		}
		else
		{
			die "ERROR: Error in fastq format, section ".($cnt+1)." doesn't start with '\@'\n";
			exit;
		}
	}	
	if($fast eq 'fasta')
	{
		if(/^>/)
		{
			$id1   = $_;
			$seq1  = <IN1>;
			$id12  = '';
			$qual1 = '';

			$id2   = <IN2>;
			$seq2  = <IN2>;
			$id22  = '';
			$qual2 = '';
		}
		else
		{
			die "ERROR: Error in fasta format, section ".($cnt+1)." doesn't start with '\@'\n";
			exit;
		}
	}	
	my($id, $idp);
	my $ind = index($id1, " ");
	$ind--;
	if($ind > 0) #new version of the header
	{
		$id  = substr($id1, 1, $ind); #starts from 1 to get rid of the '@'
		$idp = substr($id2, 1, $ind);
	}
	else #old version of the header
	{
		$id  = substr($id1, 1, -3); #it has \n at the end
		$idp = substr($id2, 1, -3);
	}
	
	#print STDERR "$id\t$idp\n";
	if($id ne $idp)
	{
		chomp $id1; chomp $id2;
		die "ERROR: sequence pair id is not the same: '$id1', '$id2'\n" 
	}
	$inx{$id}-- if(defined $inx{$id});
	$id = defined $inx{$id}? 1: 0;
	if(($keep && $id) || (!$keep && !$id))
	{
		$cnx++;
		print O1 "$id1$seq1$id12$qual1";
		print O2 "$id2$seq2$id22$qual2";
	}
	#last if($cnt >= 5029);
}
close IN1;
close IN2;
close O1;
close O2;
print STDERR "processed $cnt, printed $cnx sequence pairs ($cnt - $cnx = ".($cnt - $cnx).")\n";

$cnt = 0;
$cnx = 0;
foreach(sort keys %inx)
{
	$cnt++ if($inx{$_} == 1);
	$cnx++ if($inx{$_} < 0);
}
print STDERR "filter ids summary: $cnt was not found in the fastq files, $cnx was found more than once (very bad if this number is more than 0)\n";
print STDERR "Done.\n";
