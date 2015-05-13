package t::ForkHelper;

# Common code related to tests that need to fork a child process, with LDT
# specifics.

use IPC::LDT;

use IO::Pipe;

use Exporter ();
@ISA = qw(Exporter);
@EXPORT = qw(fork_inOut_ldt);

# Given two subroutinges &$parent and &$child runs one in the parent process and
# the second one in the child process.  Creates a set of pipes, wraps them with
# LDT objects and passes thoes as arguments to both &$parent and &$child subs.
# Arguments:
#   &$parent($in, $out) - a sub to run on the parent process.
#   &$child($in, $out) - a sub to run on the child process.
# Returns:
#   Whatever &$parent() returned.
sub fork_inOut_ldt {
   my ($parent, $child) = @_;

   # Two pipes for a two way communication with the child process. "Parent to
   # Child" and "Child to Parent".
   my $pipePC = IO::Pipe->new;
   my $pipeCP = IO::Pipe->new;

   my $pid;

   if ($pid = fork()) {
      $pipePC->writer;
      $pipeCP->reader;

      return &$parent(IPC::LDT->new(handle => $pipeCP),
                      IPC::LDT->new(handle => $pipePC));
   }
   elsif (defined $pid) {
      $pipePC->reader;
      $pipeCP->writer;

      &$child(IPC::LDT->new(handle => $pipePC),
              IPC::LDT->new(handle => $pipeCP));
   }
   else {
      die "Fork failed: $!\n";
   }
}

1;
