#!/usr/bin/perl -w
use strict;
use warnings;

my $block = 2000;
my $min = 1000;

my($cnt, $cnx);


my($id, $seq);
while(<>)
{
	chomp;
	if(/^>(\w+)/)
	{
		process() if(defined $id);
		$id  = $1;
		$seq = '';
	}
	else
	{
		$seq .= $_;
	}	
}
process() if(defined $id);
exit;

sub process
{
	for(my $i = 0; $i * $block < length($seq); $i++)
	{
		my $l = ($i + 1) * $block < length($seq)? $block: length($seq) - ($i * $block);
		#print "".($i * $block)." $l ".length($seq)."\n";
		next if($l < $min);
		my $s = substr($seq, $i * $block, $l);
		$s =~ s/(.{80})/$1\n/g;
		$s = substr($s, 0, -1) if($s =~ /\n$/);
		printf(">%s_%d\n%s\n", $id, $i + 1, $s);
	}
}