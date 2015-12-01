#!/usr/bin/perl -w
use warnings;
use strict;
use BioInfo;

my %ids;
my $cnt = 0;

my($id, $seq);
while(<>)
{
	chomp;
	if(/>((\S+).*)/)
	{
		print ">$id\n".formatFaSeq(translate($id, $seq), 80) if(defined $id);
		print STDERR "WARNING: nasty defline $2 abriged to $1\n" if($1 ne $2);
		$cnt++;
		$id = $1;
		$ids{$id}++;
		$seq = '';
	}
	else
	{
		$seq .= $_;
	}
}
print ">$id\n".formatFaSeq(translate($id, $seq), 80) if(defined $id);

foreach(keys %ids)
{
	print STDERR "ERROR: id $_ was used $ids{$id} times\n" if($ids{$id} > 1);
}

print STDERR "processed $cnt sequences\nDONE.\n";

sub translate
{
	my($id, $dna) = @_;
	my $pept;
	
	print STDERR "WARNING: $id doesn't start with ATG\n" if(uc(substr($dna, 0, 3)) ne 'ATG');
	print STDERR "WARNING: $id doesn't end with STOP\n" if(codon2aa(substr($dna, -3)) ne '*');
	for(my $i = 0; $i < length($dna); $i += 3)
	{
		my $c = substr($dna, $i, 3);
		my $a = codon2aa($c);
		if(!defined $a)
		{
			print STDERR "ERROR: $id has unknown codon $c ($i of ".(length($dna)).")\n";
		}
		else
		{
			print STDERR "ERROR: $id has STOP in the middle of the sequence ($i of ".(length($dna)).")\n" if($a eq '*' && $i < length($dna) - 3);
			$pept .= $a;
		}
	}
	return $pept;
}

