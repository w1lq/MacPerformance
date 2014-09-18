use lib (SimRunner);
use StaticVars;
use strict;

use constant SUCCESS => 0;
use constant FAILURE => 1;
use constant INVALID => 2;

use constant TRUE  => 1;
use constant FALSE => 0;

my $TOPOLOGY = StaticVars->instance()->{TOPOLOGY};
my $TIMER = StaticVars->instance()->{TIMER};
my $MAC = StaticVars->instance()->{MAC};
my $POWERTOSSIMZ = StaticVars->instance()->{POWERTOSSIMZ};
my $PACKET = StaticVars->instance()->{PACKET}->{'12kb'};
my $TOPOLOGY_PATH = StaticVars->instance()->{TOPOLOGY_PATH};

foreach my $mac_val (keys %$MAC)
{
	foreach my $timer_val (keys %$TIMER)
	{
		foreach my $topology_val (keys %$TOPOLOGY)
		{
			my $cflags_string = "\"-D$POWERTOSSIMZ -D$MAC->{$mac_val} -D$TOPOLOGY->{$topology_val} -D$TIMER->{$timer_val} -D$PACKET\"";
			if(SUCCESS != system("make micaz sim CFLAGS=$cflags_string"))
			{
				print "DUPA COS POSZLO ZLE\n";
				exit(FAILURE);
			}
			my $is_ok = TRUE;
			do
			{
				if(SUCCESS != system(
					"perl SimRunner.pl $MAC->{$mac_val}, $TOPOLOGY->{$topology_val}, $TIMER->{$timer_val}, $PACKET, $TOPOLOGY_PATH->{$topology_val}"))
				{
					$is_ok = FALSE;
				}
			} while (!$is_ok);
		}
	}
}
exit(SUCCESS);
