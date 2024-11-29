#!/usr/bin/env perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Text::CSV;
use Text::CSV_XS;
use Data::Dump qw (dump);

use constant ENSEMBL_RELEASE => 113;

# check number of input parameters
my $num_args = $#ARGV + 1;
if ($num_args != 2) {
	die("Require input species name and output directory as parameters.")	
}

# set species from input variable
my @args = @ARGV;
my $species = $args[0];
my $output_dir = $args[1];
chomp($species);
chomp($output_dir);

# check if a csv file exists already
my $output_filename = "${output_dir}/${species}_introns_" . ENSEMBL_RELEASE . ".csv";
if (-e $output_filename) {
	warn("Species csv file already exists for ${species}.");
	exit;
}

# Connect to EnsEMBL
print("Connecting to EnsEMBL for ${species} (please be patient)...\n");
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
	-host => 'useastdb.ensembl.org',
	-user => 'anonymous',
	-verbose => '1',
	-port => '5306',
	-species => $species,
);
print("Connected\n");

# Get gene adaptor
print("Loading gene adaptor for ${species}...\n");
my $gene_adaptor = $registry->get_adaptor( $species, 'Core', 'Gene');

# Setup CSV object
print("Creating output file...\n");
my $csv = Text::CSV->new({binary => 1, eol => $/}) or die "Failed to create a CSV handle: $!";
my $filename = "${output_dir}/${species}_introns_" . ENSEMBL_RELEASE . ".csv";
open my $fh, ">:encoding(utf8)", $filename or die "Failed to create $filename: $!";
my @heading = ("Species", "GeneID", "TranscriptID", "Start", "End", "Length");
$csv->print($fh, \@heading);

# Get list of gene IDs
print("Retrieving protein coding genes for ${species}...\n");
my @genes = @{$gene_adaptor->fetch_all_by_biotype('protein_coding')};

# Iterate over genes
print("Retrieving introns from canonical transcripts for ${species}...\n");
foreach my $gene (@genes) {
	foreach my $transcript ($gene->canonical_transcript) {
		foreach my $intron (@{$transcript->get_all_Introns()}) {
			my @datarow = (
				$species,
				$gene->stable_id(),
				$transcript->stable_id(),
				$intron->start(),
				$intron->end(),
				$intron->length()
			);
			$csv->print($fh, \@datarow);
		}
	}
}
close $fh or die "Failed to close $output_filename: $!";