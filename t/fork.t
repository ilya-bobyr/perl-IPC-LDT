# Simple communication with a child process.

use IPC::LDT qw(LDT_OK);

use t::ForkHelper;

use Test::More tests => 14;


sub parent {
   my ($in, $out) = @_;

   my @data;

   $in->setAsciiMode;
   $out->setAsciiMode;

   my $msg1 = "The first text message to be send.\nContains a new line.";
   my @msg2 = ("Multi-", "part", " messages", " are", " concateneated.");

   $out->send($msg1);
   @data = $in->receive;

   is($out->{rc}, LDT_OK, "ASCII mode.  First send() is OK.");
   is($in->{rc}, LDT_OK, "ASCII mode.  First receive() is OK.");
   is($data[0], $msg1, "ASCII mode.  First message.");
   is(scalar @data, 1, "ASCII mode.  First message is in one peice.");

   $out->send(@msg2);
   @data = $in->receive;

   is($out->{rc}, LDT_OK, "ASCII mode.  Second send() is OK.");
   is($in->{rc}, LDT_OK, "ASCII mode.  Second receive() is OK.");
   is($data[0], join('', @msg2), "ASCII mode.  Second message.");
   is(scalar @data, 1, "ASCII mode.  First message is in one peice.");

   $in->setObjectMode;
   $out->setObjectMode;

   my $scalar = 731;
   my @array = (51, 31, 17);
   my %hash = (l => 'loreum', n => 96);

   $out->send($scalar, \$scalar, \@array, \%hash);

   my @data = $in->receive;

   is($out->{rc}, LDT_OK, "Object mode.  First send() is OK.");
   is($in->{rc}, LDT_OK, "Object mode.  First receive() is OK.");
   is($data[0], $scalar, "Object mode.  Scalar");
   is_deeply($data[1], \$scalar, "Object mode.  Scalar ref");
   is_deeply($data[2], \@array, "Object mode.  Array ref");
   is_deeply($data[3], \%hash, "Object mode.  Hash ref");
}

sub child {
   my ($in, $out) = @_;

   my @data;

   $in->setAsciiMode;
   $out->setAsciiMode;

   @data = $in->receive;
   $out->send(@data);

   @data = $in->receive;
   $out->send(@data);

   $in->setObjectMode;
   $out->setObjectMode;

   @data = $in->receive;
   $out->send(@data);
}

&fork_inOut_ldt(\&parent, \&child);
