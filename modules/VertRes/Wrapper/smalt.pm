=head1 NAME

VertRes::Wrapper::smalt - wrapper for smalt for mapper comparison

=head1 SYNOPSIS

[stub]

=head1 DESCRIPTION

> smalt index -k 13 -s 4 <hash name> <fasta file>
This produces two files <hash name>.sma and <hash name>.smi
For > 70bp Illumina data of the human genome, '-s 6' should be sufficiently sensitive when generating the hash index. 

> smalt map -f samsoft -o <out> <hash name> <fastq file A> <fastq file B>


=head1 AUTHOR

Sendu Bala: bix@sendu.me.uk

=cut

package VertRes::Wrapper::smalt;

use strict;
use warnings;
use File::Copy;
use VertRes::IO;

use base qw(VertRes::Wrapper::MapperI);


=head2 new

 Title   : new
 Usage   : my $wrapper = VertRes::Wrapper::smalt->new();
 Function: Create a VertRes::Wrapper::smalt object.
 Returns : VertRes::Wrapper::smalt object
 Args    : quiet   => boolean

=cut

sub new {
    my ($class, @args) = @_;
    
    my $self = $class->SUPER::new(@args, exe => '/lustre/scratch102/user/sb10/mapper_comparisons/mappers/smalt-0.2.8/smalt_x86-64');
    
    return $self;
}

=head2 version

 Title   : version
 Usage   : my $version = $obj->version();
 Function: Returns the program version.
 Returns : string representing version of the program 
 Args    : n/a

=cut

sub version {
    return 0;
}

=head2 setup_reference

 Title   : setup_reference
 Usage   : $obj->setup_reference($ref_fasta);
 Function: Do whatever needs to be done with the reference to allow mapping.
 Returns : boolean
 Args    : n/a

=cut

sub setup_reference {
    my ($self, $ref) = @_;
    
    my @suffixes = qw(small.sma small.smi large.sma large.smi);
    my $indexed = 0;
    foreach my $suffix (@suffixes) {
        if (-s "$ref.$suffix") {
            $indexed++;
        }
    }
    
    unless ($indexed == @suffixes) {
        # we produce two sets of hashes, one for <70bp reads, one for >70bp
        $self->simple_run("index -k 13 -s 4 $ref.small $ref");
        $self->simple_run("index -k 13 -s 6 $ref.large $ref");
        
        $indexed = 0;
        foreach my $suffix (@suffixes) {
            if (-s "$ref.$suffix") {
                $indexed++;
            }
        }
    }
    
    return $indexed == @suffixes ? 1 : 0;
}

=head2 setup_fastqs

 Title   : setup_fastqs
 Usage   : $obj->setup_fastqs($ref_fasta, @fastqs);
 Function: Do whatever needs to be done with the fastqs to allow mapping.
 Returns : boolean
 Args    : n/a

=cut

sub setup_fastqs {
    my ($self, $ref, @fqs) = @_;
    
    foreach my $fq (@fqs) {
        if ($fq =~ /\.gz$/) {
            my $fq_new = $fq;
            $fq_new =~ s/\.gz$//;
            
            unless (-s $fq_new) {
                my $i = VertRes::IO->new(file => $fq);
                my $o = VertRes::IO->new(file => ">$fq_new");
                my $ifh = $i->fh;
                my $ofh = $o->fh;
                while (<$ifh>) {
                    print $ofh $_;
                }
                $i->close;
                $o->close;
            }
        }
    }
    
    return 1;
}

=head2 generate_sam

 Title   : generate_sam
 Usage   : $obj->generate_sam($out_sam, $ref_fasta, @fastqs);
 Function: Do whatever needs to be done with the reference and fastqs to
           complete mapping and generate a sam/bam file.
 Returns : boolean
 Args    : n/a

=cut

sub generate_sam {
    my ($self, $out, $ref, @fqs) = @_;
    
    unless (-s $out) {
        # settings change depending on read length
        my $max_length = 0;
        foreach my $fq (@fqs) {
            my $pars = VertRes::Parser::fastqcheck->new(file => "$fq.fastqcheck");
            my $length = $pars->max_length();
            if ($length > $max_length) {
                $max_length = $length;
            }
        }
        my $hash_name;
        if ($max_length < 70) {
            $hash_name = $ref.'.small';
        }
        else {
            $hash_name = $ref.'.large';
        }
        
        foreach my $fq (@fqs) {
            $fq =~ s/\.gz$//;
        }
        
        $self->simple_run("map -f samsoft -o $out $hash_name @fqs");
    }
    
    return -s $out ? 1 : 0;
}

=head2 add_unmapped

 Title   : add_unmapped
 Usage   : $obj->add_unmapped($sam_file, $ref_fasta, @fastqs);
 Function: Do whatever needs to be done with the sam file to add in unmapped
           reads.
 Returns : boolean
 Args    : n/a

=cut

sub add_unmapped {
    my $self = shift;
    return 1;
}

=head2 do_mapping

 Title   : do_mapping
 Usage   : $wrapper->do_mapping(ref => 'ref.fa',
                                read1 => 'reads_1.fastq',
                                read2 => 'reads_2.fastq',
                                output => 'output.sam');
 Function: Run mapper on the supplied files, generating a sam file of the
           mapping. Checks the sam file isn't truncated.
 Returns : n/a
 Args    : required options:
           ref => 'ref.fa'
           output => 'output.sam'

           read1 => 'reads_1.fastq', read2 => 'reads_2.fastq'
           -or-
           read0 => 'reads.fastq'

=cut

=head2 run

 Title   : run
 Usage   : Do not call directly: use one of the other methods instead.
 Function: n/a
 Returns : n/a
 Args    : paths to input/output files

=cut

1;
