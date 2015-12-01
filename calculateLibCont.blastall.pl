#!/usr/bin/perl -w

################################################################################
#
#       !!!!!!!!!!!!!!!!!!!!! IMPORTANT !!!!!!!!!!!!!!!!!!!!!
#
# before running this script make RAM disk using commands:
# sudo mkdir /tmp/ramdisk; chmod 777 /tmp/ramdisk
# sudo mount -t tmpfs -o size=50G tmpfs /tmp/ramdisk/
#
################################################################################

use strict;
use warnings;

$| = 1;
use Cwd;
use File::Basename;
use File::Temp qw(tempfile);
use threads;
use threads::shared;

#threads control
my $TMAX = 2; #number of threads to use
my %T: shared;

#semaphores
my $outFile: shared;

my $querry = $ARGV[0]; #the querry file
my $ISTART = $ARGV[1]; #index of library to start with (skip the first ones)

print STDERR "using querry file $querry\n";

my @Lib;
push @Lib, 'R1D01m';
push @Lib, 'R1D02m';
push @Lib, 'R1D0B1';
push @Lib, 'R1D0B3';
push @Lib, 'R1D0T1';
push @Lib, 'R1D0T3';
push @Lib, 'R1D0xm';
push @Lib, 'R1D0zm';
push @Lib, 'R1D1B1';
push @Lib, 'R1D1T3';
push @Lib, 'R1D2B1';
push @Lib, 'R1D2T3';
push @Lib, 'R1DxB1';
push @Lib, 'R1DxT3';
push @Lib, 'R1DzB1';
push @Lib, 'R1DzT3';
push @Lib, 'R2D01m';
push @Lib, 'R2D02m';
push @Lib, 'R2D0B1';
push @Lib, 'R2D0B3';
push @Lib, 'R2D0T1';
push @Lib, 'R2D0T3';
push @Lib, 'R2D0xm';
push @Lib, 'R2D0zm';
push @Lib, 'R2D1T3';
push @Lib, 'R2D2B1';
push @Lib, 'R2D2T3';
push @Lib, 'R2DxB1';
push @Lib, 'R2DxT3';
push @Lib, 'R2DzB1';
push @Lib, 'R2DzT3';
push @Lib, 'R3D01m';
push @Lib, 'R3D02m';
push @Lib, 'R3D0B1';
push @Lib, 'R3D0B3';
push @Lib, 'R3D0T1';
push @Lib, 'R3D0T3';
push @Lib, 'R3D0xm';
push @Lib, 'R3D0zm';
push @Lib, 'R3D1B1';
push @Lib, 'R3D1T3';
push @Lib, 'R3D2B1';
push @Lib, 'R3D2T3';
push @Lib, 'R3DxB1';
push @Lib, 'R3DxT3';
push @Lib, 'R3DzB1';
push @Lib, 'R3DzT3';


for(my $i = $ISTART; $i < scalar @Lib; $i++)
{
	process($Lib[$i], $i);
}
joinThreads(1);
print STDERR "DONE.\n";

sub process
{
	joinThreads();
	my $t = threads->new(\&work, @_);
	$T{$t->tid()} = 1;
}#process


sub joinThreads
{
	my $all = shift;
	
	while(($all && scalar(keys %T) > 0) || (scalar(keys %T) >= $TMAX)) #waiting for a free thread
	{
		foreach my $tid(keys %T)
		{
			if(!$T{$tid})
			{
				my $t = threads->object($tid);
				if($t)
				{
					$t->join();
					delete $T{$tid};
				}
				else
				{
					print "ERROR - joining of thread tid=$tid FAILED\n";
				}
			}
		}
		sleep(1);
	}
}#joinThreads

sub work
{
	my($db, $i) = @_;

	my $TmpTmpl = 'blastXXXXX';
	my($fh, $fname) = tempfile($TmpTmpl, DIR => getcwd(), SUFFIX => '.xml', UNLINK => 1);

	print STDERR "Lib $db $i of ".(scalar @Lib)."\n";
	my %Ids;
	my $timeBlast = time();
	#print STDERR "Lib $db is being copied to RAM disk\n";
	system("cp db/$db.* /tmp/ramdisk/");
	print STDERR "Lib $db blast start\n";
	my $cmd = "blastall -p blastn -m 7 -F F -v 10000000 -b 10000000 -d /tmp/ramdisk/$db -e 1e-10 -a 12 -i /tmp/ramdisk/$querry -o $fname";
	print STDERR "Lib $db ERROR: blastall returned non-zero exit code\n" if(system($cmd));
	my @a = `grep "<Hit_id>" $fname| cut -d ">" -f 2| cut -d "<" -f 1`;
	foreach(@a)
	{
		$Ids{$_} = 1;
	}
	$timeBlast = time() - $timeBlast;
	my $h = int($timeBlast / 3600);
	my $m = int(($timeBlast - $h * 3600) / 60);
	my $s = $timeBlast - $h * 3600 - $m * 60;
	print STDERR "Lib $db got $#a hits and ".(scalar keys %Ids)." unique hits, time: ".sprintf("%d:%02d:%02d\n", $h, $m, $s);
	unlink($fname);
	system("rm /tmp/ramdisk/$db.*");
	lock $outFile;
	print "$db\t".(scalar keys %Ids)."\n";
	$T{threads->self->tid()} = 0;
}#work
