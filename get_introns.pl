use Bio::EnsEMBL::Registry;
use Text::CSV;

# Connect to EnsEMBL
printf("Connecting to EnsEMBL...\n");
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
	-host => 'ensembldb.ensembl.org',
	-user => 'anonymous'
);

# Define species
my $species = "danio_rerio";

# Get gene adaptor
my $gene_adaptor = $registry->get_adaptor( $species, 'Core', 'Gene');

# Setup CSV object
my $csv = Text::CSV->new({binary => 1, eol => $/}) or die "Failed to create a CSV handle: $!";
my $filename = "${species}_introns.csv";
open my $fh, ">:encoding(utf8)", $filename or die "Failed to create $filename: $!";
my @heading = ("GeneID", "TranscriptID", "Start", "End", "Length");
$csv->print($fh, \@heading);

# Get list of gene IDs
printf("Retrieving genes for %s...\n", $species);
my @genes = @{$gene_adaptor->fetch_all_by_biotype('protein_coding')};

# Iterate over genes
printf("Retrieving introns for %s...\n", $species);
foreach my $gene (@genes) {
	foreach my $transcript ($gene->canonical_transcript) {
		foreach my $intron (@{$transcript->get_all_Introns()}) {
			my @datarow = ($gene->stable_id(),
				$transcript->stable_id(),
				$intron->start(),
				$intron->end(),
				$intron->length());
			$csv->print($fh, \@datarow);
		}
	}
}

close $fh or die "Failed to close $filename: $!";
