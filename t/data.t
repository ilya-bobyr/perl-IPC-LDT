
# This is a test script of IPC::LDT,
# using file handles to check the
# transfer of Perl data.


# load modules
use IPC::LDT;
use FileHandle;
use Test::More tests => 4;

# build temporary filename
my $file="/tmp/.$$.ipc.ldt.tmp";

# init the data to transfer
my $scalar=50;
my @array=(3, 7, 15);
my %hash=(a=>'A', z=>'Z');
my $ref=\$IPC::LDT::VERSION;

# write message
{
 # open file
 open(O, ">$file") or die "[Fatal] Could not open $file for writing.\n";

 # build LDT object
 my $ldt=new IPC::LDT(handle=>*O, objectMode=>1) or die "[Fatal] Could not build LDT object.\n";

 # send data
 $ldt->send($scalar, \@array, \%hash, $ref);

 # close the temporary file
 close(O);
}


# read message
{
 # open file
 open(I, $file) or die "[Fatal] Could not open $file for reading.\n";

 # build LDT object
 my $ldt=new IPC::LDT(handle=>*I, objectMode=>1) or die "[Fatal] Could not build LDT object.\n";

 # read data
 my @data=$ldt->receive;

 # perform the checks
 is($data[0], $scalar, "Scalar stored correctly");
 is_deeply($data[1], \@array, "Array stored correctly");
 is_deeply($data[2], \%hash, "Hash stored correctly");
 is_deeply($data[3], $ref, "Reference stored correctly");

 # close the temporary file
 close(I);
}

# clean up
unlink $file;
