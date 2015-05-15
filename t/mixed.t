
# This is a test script of IPC::LDT,
# using file handles to check the
# switching between ASCII and object mode.
# (This is just a combination of ascii.t and data.t.)

use Test::More tests => 12;

use IPC::LDT;

use IO::File;
use Fcntl 'SEEK_SET';

my $file = IO::File->new_tmpfile;

my $msg = "This is a simple\nmultiline check message.";
my @msg = ('This message', "contains\nof", 'several parts.');
my $scalar = 50;
my @array = (3, 7, 15);
my %hash = (a => 'A', z => 'Z');
my $ref = \$IPC::LDT::VERSION;

# write message
{
 my $ldt = new IPC::LDT(handle => $file)
     or die "[Fatal] Could not build LDT object.\n";

 $ldt->setAsciiMode;
 $ldt->send($msg);
 $ldt->send(@msg);

 $ldt->setObjectMode;
 $ldt->send($scalar, \@array, \%hash, $ref);

 $ldt->setAsciiMode;
 $ldt->send($msg);
 $ldt->send(@msg);

 $ldt->setObjectMode;
 $ldt->send($scalar, \@array, \%hash, $ref);
}

$file->seek(0, SEEK_SET);

# read message
{
 my $ldt = new IPC::LDT(handle => $file)
     or die "[Fatal] Could not build LDT object.\n";

 $ldt->setAsciiMode;
 my $read1 = $ldt->receive;
 my $read2 = $ldt->receive;

 $ldt->setObjectMode;
 my @data1 = $ldt->receive;

 $ldt->setAsciiMode;
 my $read3 = $ldt->receive;
 my $read4 = $ldt->receive;

 $ldt->setObjectMode;
 my @data2 = $ldt->receive;

 is($read1, $msg, "One part multiline message.1");
 is($read2, join('', @msg), "Multipart message.1");

 is($read3, $msg, "One part multiline message.2");
 is($read4, join('', @msg), "Multipart message.2");

 is($data1[0], $scalar, "Scalar stored correctly.1");
 is_deeply($data1[1], \@array, "Array stored correctly.1");
 is_deeply($data1[2], \%hash, "Hash stored correctly.1");
 is_deeply($data1[3], $ref, "Reference stored correctly.1");

 is($data2[0], $scalar, "Scalar stored correctly.2");
 is_deeply($data2[1], \@array, "Array stored correctly.2");
 is_deeply($data2[2], \%hash, "Hash stored correctly.2");
 is_deeply($data2[3], $ref, "Reference stored correctly.2");
}
