use strict;
use warnings;
use Test::More;
use File::Temp qw(tempfile);

# extract getPacketData sub from SimRunner.pl without executing script
my $code;
{
    local $/;
    open my $fh, '<', 'SimRunner.pl' or die $!;
    $code = <$fh>;
    close $fh;
}
my ($sub_code) = $code =~ /(sub getPacketData.*?^\})/ms;
ok($sub_code, 'found getPacketData function');
$sub_code =~ s/sub getPacketData\([^\)]*\)/sub getPacketData/;  # strip prototype for newer perls
{
    no warnings 'redefine';
    eval $sub_code;
    die $@ if $@;
}

my ($fh, $file) = tempfile();
print $fh "0: PacketState: Sent: 0 ; 100\n";
print $fh "0: PacketState: Recieved: 0 ; 120\n";
print $fh "1: PacketState: Sent: 1 ; 150\n";
print $fh "1: PacketState: Recieved: 1 ; 180\n";
close $fh;

my $res = getPacketData($file);

ok(!exists $res->{sent}{'0'}, 'ghost node not in sent');
ok(!exists $res->{recieved}{'0'}, 'ghost node not in recieved');

done_testing();
