
# This is a test script of IPC::LDT,
# using file handles to check the
# transfer of Perl data.

use Test::More tests => 4;

use IPC::LDT;

use IO::File;
use Fcntl 'SEEK_SET';

my $file = IO::File->new_tmpfile;

my $scalar = 50;
my @array = (3, 7, 15);
my %hash = (a => 'A', z => 'Z');
my $ref = \$IPC::LDT::VERSION;

# write message
{
    my $ldt = new IPC::LDT(handle => $file, objectMode => 1)
        or die "[Fatal] Could not build LDT object.\n";

    $ldt->send($scalar, \@array, \%hash, $ref);
}

$file->seek(0, SEEK_SET);

# read message
{
    my $ldt = new IPC::LDT(handle => $file, objectMode => 1)
        or die "[Fatal] Could not build LDT object.\n";

    my @data = $ldt->receive;

    is($data[0], $scalar, "Scalar stored correctly");
    is_deeply($data[1], \@array, "Array stored correctly");
    is_deeply($data[2], \%hash, "Hash stored correctly");
    is_deeply($data[3], $ref, "Reference stored correctly");
}
