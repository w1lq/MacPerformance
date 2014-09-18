use lib (SimRunner);
use StaticVars;
use strict;

use constant SUCCESS => 0;
use constant FAILURE => 1;
use constant INVALID => 2;

use constant TRUE  => 1;
use constant FALSE => 0;

my $MAC = shift(@ARGV);
my $TOPOLOGY = shift(@ARGV);
my $TIMER = shift(@ARGV);
my $PACKET_SIZE = shift(@ARGV);
my $TOPOLOGY_PATH = shift(@ARGV);

my $simulation_H_ref = {};

my $static_vars = StaticVars->instance();

runSimulations($TOPOLOGY_PATH);
calculateResults();
calculateMean();
writeResults($MAC, $TOPOLOGY, $TIMER, $PACKET_SIZE);
cleanup();
exit(SUCCESS);

print "Done..\n";

sub runSimulations($;)
{
	my $topology_path = shift;
	system('mkdir TEMP');
	for(my $i = 1; $i<51; $i++)
	{
		do
		{
			eval(system("python Simulation.py -g $topology_path"));
		}
		while (SUCCESS != $? && checkParameters());
		system("cp $static_vars->{PATH}->{ENERGY} TEMP/Energy$i.txt");
		system("cp $static_vars->{PATH}->{RESULT} TEMP/Result$i.txt");
		system("cp $static_vars->{PATH}->{PACKET} TEMP/Packet$i.txt");
	}
}

sub cleanup()
{
	print "Performing cleanup...\n";
	system("rm -rf TEMP");
	$simulation_H_ref = undef;
}

sub calculateResults()
{
	for(my $i = 1; $i<51; $i++)
	{
		print "Starting to calculate simulation $i...\n";
		print "Running postprocessZ energy calculation...\n";
		if(!SUCCESS == system("python postprocessZ.py --simple TEMP/Energy$i.txt > TEMP/Temp_Energy.txt"))
		{
			exit(FAILURE);
		}
		my $energy_H_ref = getEnergyData("TEMP/Temp_Energy.txt");
		my $result_H_ref = getResultData("TEMP/Result$i.txt");
		my $packet_H_ref = getPacketData("TEMP/Packet$i.txt");
		$simulation_H_ref->{$i} = {
			delay => calculateDelay($packet_H_ref),
			throughput => calculateThroughputPerCycleRange($packet_H_ref),
			avr_throughput => calculateAvrThroughput($result_H_ref),
			fairness => calculateFairness($result_H_ref),
			e2e_loss => calculateE2eLoss($result_H_ref),
			energy => $energy_H_ref
		};
	}
}

sub writeResults($$$$;)
{
	my $mac = shift;
	my $packet_size = shift;
	my $timer = shift;
	my $topology = shift;

	my @data;

	print "Writing simulation to SimulationResults/$mac-$topology-$timer-$packet_size.txt...\n";

	push(@data, 
		"### DELAY ###\n\n",
		"delay, $simulation_H_ref->{delay}\n\n",
		"### AVERAGE THROUGHPUT ###\n\n",
		"avr_thr, $simulation_H_ref->{avr_throughput}\n\n",
		"### END TO END LOSS ###\n\n",
		"e2e, $simulation_H_ref->{e2e_loss}\n\n",
		"### FAIRNESS ###\n\n",
		"fairness, $simulation_H_ref->{fairness}\n\n",
		"### TOTAL ENERGY USAGE ###\n\n",
		"tot_ener, $simulation_H_ref->{energy}->{sum}\n\n",
		"### THROUGHPUT BY CYCLE ###\n\n",
		);
	foreach my $cycle (keys %{$simulation_H_ref->{throughput}})
	{
		push (@data, "cycle, $cycle,$simulation_H_ref->{throughput}->{$cycle}\n");
	}
	push(@data, "\n### ENERGY USAGE BY NODE ###\n\n");
	foreach my $node (keys %{$simulation_H_ref->{energy}})
	{
		push (@data, "energy, $node,$simulation_H_ref->{energy}->{$node}\n");
	}

	open(DATA, ">SimulationResults/$mac-$topology-$timer-$packet_size.txt");
	print DATA @data;
	close DATA;
}

sub calculateFairness($;)
{
	my $result_H_ref = shift;

	print "Calculating Fairness...\n";

	my $sum = 0;
	my $counter = 0;
	for(my $i = 1; $i < scalar(keys %$result_H_ref); $i++)
	{
		if(0 == $result_H_ref->{$i}->{recieved})
		{
			$counter++;
			$sum += ($result_H_ref->{$i}->{sent} * $result_H_ref->{$i}->{sent});
		}
	}
	return ($result_H_ref->{'0'}->{recieved} * $result_H_ref->{'0'}->{recieved}) / ($counter * $sum);
}

sub calculateMean()
{
	print "Calculating mean...\n";

	my $i = 0;
	my ($sum_delay, $sum_avr_throughput, $sum_e2e_loss, $sum_fairness) = 0;
	my $throughput_H_ref = {};
	my $energy_H_ref = {};
	my $final_H_ref = {};
	for(my $sim = 1; $sim <= scalar(keys %$simulation_H_ref); $sim++)
	{
		$i++;
		$sum_delay += $simulation_H_ref->{$sim}->{delay};
		$sum_fairness += $simulation_H_ref->{$sim}->{fairness};
		$sum_e2e_loss += $simulation_H_ref->{$sim}->{e2e_loss};
		$sum_avr_throughput += $simulation_H_ref->{$sim}->{avr_throughput};	
		foreach my $cycle (keys %{$simulation_H_ref->{$sim}->{throughput}})
		{
			if(!defined($throughput_H_ref->{$cycle}))
			{
				$throughput_H_ref->{$cycle} = $simulation_H_ref->{$sim}->{throughput}->{$cycle};	
			}
			else
			{
				$throughput_H_ref->{$cycle} += $simulation_H_ref->{$sim}->{throughput}->{$cycle};
			}
		} 	
		foreach my $node (keys %{$simulation_H_ref->{$sim}->{energy}})
		{
			if(!defined($energy_H_ref->{$node}))
			{
				$energy_H_ref->{$node} = $simulation_H_ref->{$sim}->{energy}->{$node};	
			}
			else
			{
				$energy_H_ref->{$node} += $simulation_H_ref->{$sim}->{energy}->{$node};
			}
		} 
	}
	foreach my $node (keys %$energy_H_ref)
	{
		$energy_H_ref->{$node} = $energy_H_ref->{$node} / $i;
		if(!defined($energy_H_ref->{sum}))
		{
			$energy_H_ref->{sum} = $energy_H_ref->{$node};
		} 
		else
		{
			$energy_H_ref->{sum} += $energy_H_ref->{$node};
		}
	}
	foreach my $cycle (keys %$throughput_H_ref)
	{
		$throughput_H_ref->{$cycle} = $throughput_H_ref->{$cycle} / $i;
	}
	$final_H_ref->{delay} = $sum_delay/$i;
	$final_H_ref->{avr_throughput} = $sum_avr_throughput / $i;
	$final_H_ref->{e2e_loss} = $sum_e2e_loss/$i;
	$final_H_ref->{fairness} = $sum_fairness /$i;
	$final_H_ref->{throughput} = $throughput_H_ref;
	$final_H_ref->{energy} = $energy_H_ref;

	$simulation_H_ref = $final_H_ref;
}

sub getResultData($;)
{
	my $path = shift;
	my $result_H_ref = {};

	print "Reading result data file...\n";

	open(DATA, "<$path");
	my @data = <DATA>;
	close DATA;

	foreach my $line (@data)
	{
		#"%d,%d,%d\n"
		if($line =~ /\A(\d+),(\d+),(\d+)\Z/)
		{
			$result_H_ref->{$1} = {
				sent => $2,
				recieved => $3
			};
		}
	}
	return $result_H_ref;
}

sub getSplitPacketData($;)
{
	my $path = shift;
	my $packet_H_ref = {
		sent => {},
		recieved => {},
	};

	open(DATA, "<$path");
	my @data = <DATA>;
	close DATA;

	foreach my $line (@data)
	{
		#"Sent: %hu ; %llu\n"
		if($line =~ /\A.*:\s(\w+):\s(\d+)\s;\s(\d+)\Z/)
		{
			my $node;
			my $pkt_id;
			if(5 == length($2))
			{
				$node = substr($2, 0, 2);
				$pkt_id = substr($2, 2, 3);
			}
			else
			{
				$node = substr($2, 0, 1);
				$pkt_id = substr($2, 2, 3);
			}
			if('sent' == $1)
			{
				$packet_H_ref->{sent}->{$node} = {
					pkt_id => $3
				};
			}
			else
			{
				$packet_H_ref->{recieved}->{$node} = {
					pkt_id => $3
				};	
			}
		}

	}
	return $packet_H_ref;
}

sub getPacketData($;)
{
	my $path = shift;
	my $packet_H_ref = {
		sent => {},
		recieved => {},
	};

	print "Reading packet data file...\n";

	open(DATA, "<$path");
	my @data = <DATA>;
	close DATA;

	foreach my $line (@data)
	{
		#"Sent: %hu ; %llu\n"
		if($line =~ /\A.*:\sSent:\s(\d+)\s;\s(\d+)\Z/)
		{
			$packet_H_ref->{sent}->{$1} = $2;
		}	
		elsif($line =~ /\A.*:\sRecieved:\s(\d+)\s;\s(\d+)\Z/)
		{
				$packet_H_ref->{recieved}->{$1} = $2;
		}
	}
	#delete ghost packages
	if(defined($packet_H_ref->{recieved}->{'0'}))
	{
		delete $packet_H_ref->{recieved}->{'0'};
	}
	if(defined($packet_H_ref->{sent}->{'0'}))
	{
		delete $packet_H_ref->{recieved}->{'0'};
	}
	return $packet_H_ref;
}

sub getEnergyData($;)
{
	my $path = shift;
	my $energy_H_ref = {};

	print "Reading Energy data file...\n";

	open(DATA, "<$path");
	my @data = <DATA>;
	close DATA;

	foreach my $line (@data)
	{
		#"0   0.0456   1122.2497   0.0000   0.0000   0.0000   0.0000   0.0000   1122.2953   1999.9174"
		if($line =~ /\A(\d+)\s+\d+\.\d+\s+(\d+\.\d+)\s+.*\Z/)
		{
			$energy_H_ref->{$1} = $2;
		}

	}
	return $energy_H_ref;
}

sub calculateThroughputPerCycleRange($;)
{
	my $packet_H_ref = shift;
	my $calculated_H_ref = {};

	print "Calculatin throughput per cycle range...\n";

	my $single_cycle = $static_vars->{MAX_SIM_CYCLES} / 20;

	for(my $i = 1; $i<21; $i++)
	{
		foreach my $time_recieved (values %{$packet_H_ref->{recieved}})
		{
			if(($i-1) * $single_cycle < $time_recieved && $time_recieved <= $i * $single_cycle)
			{
				if(!defined($calculated_H_ref->{$i*$single_cycle}))
				{
					$calculated_H_ref->{$i*$single_cycle} = 0;
				}
				$calculated_H_ref->{$i*$single_cycle} += 1;	
			}
		}		
	}
	return $calculated_H_ref;
}

sub calculateAvrThroughput($;)
{
	my $result_H_ref = shift;
	print "Calculating average throughput...\n";
	return $result_H_ref->{0}->{recieved};
}

sub calculateE2eLoss($;)
{
	my $result_H_ref = shift;
	print "Calculating end to end loss...\n";
	my $sent_total = 0;

	foreach my $node (keys %$result_H_ref)
	{
		if(0 != $node)
		{
			$sent_total += $result_H_ref->{$node}->{sent};
		}
	}

	return 1 - ($result_H_ref->{0}->{recieved} / $sent_total);
}

sub calculateDelay($;)
{
	my $packet_H_ref = shift;
	my $i = 0;
	my $sum = 0;

	print "Calculating delay...\n";

	foreach my $recieved_packet (keys %{$packet_H_ref->{recieved}})
	{

		$i++;
		$sum += ($packet_H_ref->{recieved}->{$recieved_packet} - $packet_H_ref->{sent}->{$recieved_packet});

	} 

	return $sum/$i;
}


#Checks if the sim did not crash midway 
sub checkParameters()
{

	open(DATA, "<static_vars->{PATH}->{RESULT}");
	my @data = <DATA>;
	close DATA;
	chomp(@data);

	if(shift(@data) < $static_vars->{MAX_SIM_CYCLES})
	{
		return FALSE;
	} 

	my $is_ok = TRUE;
	foreach my $line (@data)
	{
		if($line =~ /\A\d+,(\d+),0\Z/)
		{
			if($1 < 10)
			{
				$is_ok = FALSE;
			}
		}
		if($line =~ /\A0,0,(\d+)\Z/)
		{
			if($1 < 10)
			{
				$is_ok = FALSE;
			}
		}
	}
	return $is_ok;
}
