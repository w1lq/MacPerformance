use strict;
use warnings;
use Test::More tests => 2;
use FindBin;
use lib "$FindBin::Bin/../SimRunner";
use StaticVars;

my $sv = StaticVars->instance();

is($sv->{TOPOLOGY}->{CLUSTER2}, 'CLUSTER_TOPOLOGY_2', 'CLUSTER2 constant');
ok(exists $sv->{PACKET}->{'20kb'}, 'PACKET 20kb exists');
