
# Makefile.PL -- Makefile template for IPC::LDT
#
# This file is part of the "IPC::LDT" module package.
# IPC::LDT is free software, you can redistribute it
# and/or modify it under the same terms as Perl itself.

# load module
use ExtUtils::MakeMaker;

# write makefile
WriteMakefile(
              NAME         => 'IPC::LDT',
              VERSION_FROM => 'LDT.pm',
              PREREQ_PM    => {
                               Filter::Util::Call => 1,
                               Storable           => 0.6,
                              },
              dist         => {
                               COMPRESS => 'gzip -9',
                               SUFFIX   => 'tgz',
                              },
             );
