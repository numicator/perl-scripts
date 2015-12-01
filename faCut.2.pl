#!/usr/bin/perl -w
use strict;
use warnings;

my $window = 1500;
my $step   =  300;

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
	for(my $i = 0; $i < length($seq); $i += $step)
	{
		my $l = $i + $window < length($seq)? $window: length($seq) - $i;
		#print "$i $l ".length($seq)."\n"; next;
		next if($l < $window);
		my $s = substr($seq, $i, $l);
		$s =~ s/(.{80})/$1\n/g;
		$s = substr($s, 0, -1) if($s =~ /\n$/);
		printf(">%s_%d\n%s\n", $id, $i + 1, $s);
	}
}