package Pathogens::Exception;

use Exception::Class (
    Pathogens::Exception::NullDenominator =>
      { description => 'Denominator is 0' },
    Pathogens::Exception::HetSNPStepCommand =>
      { description => 'Problems running the shell command' },
    Pathogens::Exception::SystemCall =>
      { description => 'Problems running a system call' },
);

1;
