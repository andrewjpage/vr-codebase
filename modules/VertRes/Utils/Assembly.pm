=head1 NAME

VertRes::Utils::Assembly - wrapper for calling assembler and assembly optimiser

=head1 SYNOPSIS

=head1 DESCRIPTION

Provides a uniform interface for assembly so you dont need to worry about the differences between assemblers

=head1 AUTHOR

path-help@sanger.ac.uk

=cut

package VertRes::Utils::Assembly;

use strict;
use warnings;
use VertRes::IO;
use File::Basename;
use VertRes::Utils::Hierarchy;
use VertRes::Utils::FileSystem;
use VRTrack::Lane;

use base qw(VertRes::Base);

=head2 new

 Title   : new
 Usage   : my $obj = VertRes::Utils::Assembly->new();
 Function: Create a new VertRes::Utils::Assembly object.
 Returns : VertRes::Utils::Assembly object
 Args    : assember => 'velvet'|'abyss' 

=cut

sub new {
    my ($class, @args) = @_;
    
    my $self = $class->SUPER::new(@args);

    return $self;
}

=head2 find_module

 Title   : find_module
 Usage   : my $module = $obj->find_module();
 Function: Find out what assembly utility module to use
 Returns : class string (call new on it)

=cut

sub find_module {
    my ($self, $arg) = @_;
    return "VertRes::Utils::Assemblers::".$self->{assembler};
}


=head2 generate_files_str

 Title   : generate_files_str
 Usage   : my $module = $obj->generate_files_str();
 Function: create the input string for the files to go into the assembler
 Returns : string which can be passed into assembler

=cut
sub generate_files_str
{
  my $self = shift;
  $self->throw("This is supposed to be overriden");
}


1;