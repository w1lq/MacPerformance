package StaticVars;
use strict;

use File::Copy;
use File::Path;

use constant SUCCESS => 0;
use constant FAILURE => 1;
use constant INVALID => 2;

use constant TRUE  => 1;
use constant FALSE => 0;

my $_self_ref;

sub instance($;)
{
    my $class = shift;
    
    # If you already are a ref then
    # you shouldn't be calling new again.
    if ( ref($class) )
    {
        print "Cannot clone object";
        return undef;
    }

    my $self = {};

    bless $self, $class;

    $self->_initialize();
    
    return $self;
}

sub _initialize($;)
{
	my $self = shift;

	$self->{_TOPO_ROOT} = 'Topologies/';
	$self->{TOPOLOGY} = {
		CHAIN2 => 'CHAIN_TOPOLOGY_2',
		CHAIN4 => 'CHAIN_TOPOLOGY_4',
		CHAIN6 => 'CHAIN_TOPOLOGY_6',
		CHAIN8 => 'CHAIN_TOPOLOGY_8',
		CHAIN10 => 'CHAIN_TOPOLOGY_10',
		CLUSTER2 => 'CLUSTER_TOPOLOGY_2',
		CLUSTER4 => 'CLUSTER_TOPOLOGY_4',
		CLUSTER6 => 'CLUSTER_TOPOLOGY_6',
		CLUSTER8 => 'CLUSTER_TOPOLOGY_8',
		CLUSTER10 => 'CLUSTER_TOPOLOGY_10',
		TREE3 => 'TREE_TOPOLOGY_3',
		TREE5 => 'TREE_TOPOLOGY_5',
		TREE7 => 'TREE_TOPOLOGY_7',
		TREE9 => 'TREE_TOPOLOGY_9',
		TREE11 => 'TREE_TOPOLOGY_11',		
	};
	$self->{TOPOLOGY_PATH} = {
		CHAIN2 => "$self->{_TOPO_ROOT}Chain2.txt",
		CHAIN4 => "$self->{_TOPO_ROOT}Chain4.txt",
		CHAIN6 => "$self->{_TOPO_ROOT}Chain6.txt",
		CHAIN8 => "$self->{_TOPO_ROOT}Chain8.txt",
		CHAIN10 => "$self->{_TOPO_ROOT}Chain10.txt",
		CLUSTER2 => "$self->{_TOPO_ROOT}Cluster2.txt",
		CLUSTER4 => "$self->{_TOPO_ROOT}Cluster4.txt",
		CLUSTER6 => "$self->{_TOPO_ROOT}Cluster6.txt",
		CLUSTER8 => "$self->{_TOPO_ROOT}Cluster8.txt",
		CLUSTER10 => "$self->{_TOPO_ROOT}Cluster10.txt",
		TREE3 => "$self->{_TOPO_ROOT}Tree3.txt",
		TREE5 => "$self->{_TOPO_ROOT}Tree5.txt",
		TREE7 => "$self->{_TOPO_ROOT}Tree7.txt",
		TREE9 => "$self->{_TOPO_ROOT}Tree9.txt",
		TREE11 => "$self->{_TOPO_ROOT}Tree11.txt",
	};
	$self->{POWERTOSSIMZ} = 'POWERTOSSIMZ';
	$self->{MAC} = {
		BMAC => 'BMAC',
		BMACPLUS => 'BMACPLUS',
		TMAC => 'TMAC',
		SMAC => 'SMAC',
	};
	$self->{PACKET} = {
		'4kb' => 'PACKET_SIZE_4kb',
		'8kb' => 'PACKET_SIZE_8kb',
		'12kb' => 'PACKET_SIZE_12kb',
		'16kb' => 'PACKET_SIZE_16kb',
		'20kb' => 'PACKET_SIZE_20kb' 
	};
	$self->{TIMER} = {
		'60' => 'TIMER_60',
		'70' => 'TIMER_70',
		'80' => 'TIMER_80',
		'90' => 'TIMER_90',
		'100' => 'TIMER_100'
	};
	$self->{PATH} = {
		ENERGY => 'Simulation/Energy.txt',
		PACKET => 'Simulation/Packet.txt',
		RESULT => 'Simulation/Result.txt'
	};
	$self->{MAX_SIM_CYCLES} = 500000000000;
}

1;
