
# This is a test script of IPC::LDT,
# using file handles to check the
# delay feature.

use Test::More tests => 1;

use IPC::LDT;

use IO::File;
use Fcntl 'SEEK_SET';

my $file = IO::File->new_tmpfile;

# write messages
{
    my $ldt = new IPC::LDT(handle => $file)
        or die "[Fatal] Could not build LDT object.\n";

    $ldt->delay(sub { $_[0]->[0] % 2 });

    $ldt->send($_) for 1..10;

    $ldt->undelay;
}

$file->seek(0, SEEK_SET);

# read messages
{
    my $ldt = new IPC::LDT(handle => $file)
        or die "[Fatal] Could not build LDT object.\n";

    my @read;
    $read[$_ - 1] = $ldt->receive for 1..10;

    is(join('-', @read), '2-4-6-8-10-1-3-5-7-9', "Even messages delayed");
}
