# Make sure partial messages are correctly delivered.

use warnings;
use strict;

use Test::More tests => 20;

use IPC::LDT qw(LDT_OK LDT_READ_INCOMPLETE);

use t::ForkHelper;
use Time::HiRes qw(gettimeofday tv_interval);
use IO::File;
use Fcntl 'SEEK_SET';


sub _timed (&) {
   my $startTime = [gettimeofday()];
   &{ $_[0] }();
   return tv_interval($startTime);
}


my $msg1 = 'Message to be sent in chunks';

sub parent {
   my ($in, $out) = @_;

   $in->setObjectMode;
   $out->setObjectMode;

   $in->timeout(0.01);
   my (@data, $spentTime);

   $out->send(1);
   $spentTime = _timed {
      @data = $in->receive;
   };

   is($out->{rc}, LDT_OK, "sync send() successful.1");
   is($in->{rc}, LDT_READ_INCOMPLETE, "read is pending.1");
   is_deeply(\@data, [], "\@data is empty.1");
   cmp_ok($spentTime, '<', 0.1, "read timed out fast enough.1");

   $out->send(1);
   $spentTime = _timed {
      @data = $in->receive;
   };

   is($out->{rc}, LDT_OK, "sync send() successful.2");
   is($in->{rc}, LDT_READ_INCOMPLETE, "read is pending.2");
   is_deeply(\@data, [], "\@data is empty.2");
   cmp_ok($spentTime, '<', 0.1, "read timed out fast enough.2");

   $out->send(1);
   $spentTime = _timed {
      @data = $in->receive;
   };

   is($out->{rc}, LDT_OK, "sync send() successful.3");
   is($in->{rc}, LDT_READ_INCOMPLETE, "read is pending.3");
   is_deeply(\@data, [], "\@data is empty.3");
   cmp_ok($spentTime, '<', 0.1, "read timed out fast enough.3");

   $out->send(1);
   $spentTime = _timed {
      @data = $in->receive;
   };

   is($out->{rc}, LDT_OK, "sync send() successful.4");
   is($in->{rc}, LDT_READ_INCOMPLETE, "read is pending.4");
   is_deeply(\@data, [], "\@data is empty.4");
   cmp_ok($spentTime, '<', 0.1, "read timed out fast enough.4");

   $out->send(1);
   $spentTime = _timed {
      @data = $in->receive;
   };

   is($out->{rc}, LDT_OK, "sync send() successful.5");
   is($in->{rc}, LDT_OK, "read was successful.5");
   is_deeply(\@data, [$msg1], "message was transferred.5");
   cmp_ok($spentTime, '<', 0.1, "read completed fast enough.5");
}

sub child {
   my ($in, $out) = @_;

   use bytes;

   $in->setObjectMode;
   $out->setObjectMode;

   # We will first generate our message.  Then we will send it in short chunks,
   # to simulate delays.  One chunk every time parent sends us something.

   my $tempFile = IO::File->new_tmpfile;
   my $hold = IPC::LDT->new(handle => $tempFile, objectMode => 1);

   $hold->send($msg1);

   $tempFile->seek(0, SEEK_SET);
   my $buf;
   1 while $tempFile->read($buf, 1024, length($buf));

   my $outPipe = $out->{handle};

   # $in is used for synchronization.
   $in->receive;
   syswrite($outPipe, $buf, 1, 0);

   $in->receive;
   syswrite($outPipe, $buf, 2, 1);

   $in->receive;
   syswrite($outPipe, $buf, 4, 3);

   $in->receive;
   syswrite($outPipe, $buf, 8, 7);

   $in->receive;
   syswrite($outPipe, $buf, length($buf) - 15, 15);
}


&fork_inOut_ldt(\&parent, \&child);
