
# This is a test script of IPC::LDT,
# using file handles to check the
# transfer of ASCII strings.

use Test::More tests => 2;

use IPC::LDT;

use IO::File;
use Fcntl 'SEEK_SET';

my $file = IO::File->new_tmpfile;

my $msg = "This is a simple\nmultiline check message.";
my @msg = ('This message', "contains\nof", 'several parts.');


# write messages
{
    my $ldt = new IPC::LDT(handle => $file)
        or die "[Fatal] Could not build LDT object.\n";

    $ldt->send($msg);
    $ldt->send(@msg);
}

$file->seek(0, SEEK_SET);

# read messages
{
    my $ldt = new IPC::LDT(handle => $file)
        or die "[Fatal] Could not build LDT object.\n";

    my $read1 = $ldt->receive;
    my $read2 = $ldt->receive;

    is($read1, $msg, "One part multiline message");
    is($read2, join('', @msg), "Multipart message");
}
