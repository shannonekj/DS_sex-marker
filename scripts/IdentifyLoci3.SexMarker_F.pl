#!/usr/bin/perl

#######################################################################################
$max_alignment_score = 30;
$divergence_factor = 3;
$min_count = 0; #zero turns off to use min_flag instead
$min_flag = 0; #zero turns off to use min_count instead
$max_internal_alignments = 0; # use 0 for sex chromosome, 1 if diploid
$min_internal_alignments = 0;
$max_external_alignments = 3; # twice the df of the total number of samples (i.e. individuals) in the alignment
$min_external_alignments = 2; # approximately half of the df of the total number of samples (i.e. individuals) in the alignment
$max_total_alignments = 3; # max_ext_align + max_int_align
$min_total_alignments = 2; # min_ext_align + min_int_align
$min_alleles = 1;
$max_alleles = 2;
$min_samples_per_allele = 1;
$max_samples_per_allele = 4; # total number of samples (i.e. individuals) in the alignment
#######################################################################################
# This script was created by Michael Miller.
#######################################################################################


$file = $ARGV[0];

open(FILE, "<$file") or die;
while (<FILE>) {
	$line = $_;
	chomp($line);
	if (substr($line,0,1) eq ">") {
		@tabs = split(/\t/,$line);

		if ($tabs[9] eq "F") {

			$query = $tabs[0];
	                ($query_lib, $query_ID, $query_count, $query_flag) = split(/\;/, $query);
	                $query_sequence = $tabs[2];

			if ($query_used{$query} != 1 && $query_count >= $min_count && $query_flag >= $min_flag) {
				$query_sequences{$query} = $query_sequence;
				$sample_count{$query_sequence}++;
				$query_used{$query} = 1;
			}

		}		

	}
}
close(FILE);
%query_used = (); #clear this hash to clear memory


open(FILE, "<$file") or die;
while (<FILE>) {

	$line = $_;
	chomp($line);

	if (substr($line,0,1) eq ">") {
		@tabs = split(/\t/,$line);

		if ($tabs[9] eq "F") {

			$query = $tabs[0];
			($query_lib, $query_ID, $query_count, $query_flag) = split(/\;/, $query); 
			$index = $tabs[7]; 
			($index_lib, $index_ID, $index_count, $index_flag) = split(/\;/, $index);
		
			$score = $tabs[5];
			$change = $tabs[13];
			$query_sequence = $tabs[2];
			$index_sequence = $query_sequences{$index};

			if ( ($query ne $index) && ( $sample_count{$query_sequence} >= $min_samples_per_allele && $sample_count{$query_sequence} <= $max_samples_per_allele ) && ( $sample_count{$index_sequence} >= $min_samples_per_allele && $sample_count{$index_sequence} <= $max_samples_per_allele ) ) {

				if ($query_lib eq $index_lib) {		
						push(@{$internal_alignments{$query}}, $index);
						push(@{$internal_alignment_scores{$query}}, $score);
				} else {
					if ($score == 0) {
						push(@{$perfect_external_alignments{$query}}, $index);
						push(@{$external_alignments{$query}}, $index);
						push(@{$external_alignment_scores{$query}}, $score);
					} else {
						push(@{$external_alignments{$query}}, $index);
						push(@{$external_alignment_scores{$query}}, $score);
					}
				}

			}	

		}

	}
}
close(FILE);

$locus = 1;
foreach $query (keys %query_sequences) {
	if ($printed{$query} != 1) {
	
		$bad = 0;
		@alleles = valid_alignments($query);
		$string1 = "@alleles";

		if ($string1 ne "") {
			foreach (@alleles) {
				@alleles2 = valid_alignments($_);
				$string2 = "@alleles2";
				if ($string1 ne $string2) { $bad = 1; }
			}
			if ($bad != 1) {
				$print_string = ""; $print_count = 0;
				foreach (@alleles) {
					if ($printed{$_} != 1) {
						@matches = ($_, @{$perfect_external_alignments{$_}});
						@matches = sort(@matches);

						$ID = "";
						foreach (@matches) { 
							$ID = $ID . substr($_,1,length($_)) . "|"; 
							$printed{$_} = 1;	
						}
						chop($ID);

						$plocus = sprintf("%06d", $locus); $plocus = "R" . $plocus;
						$print_string = $print_string . ">$plocus\{$ID\}\n";
						$print_string = $print_string . $query_sequences{$_} . "\n";
						$print_count++;
					}
				}
				if ($print_count >= $min_alleles && $print_count <= $max_alleles) {
					print $print_string;
					$locus++;
				}
			}
		}

	}
}

sub valid_alignments {
	$seq = $_[0];
	@int_aligns = ();
	@ext_aligns = ();
	@aligns = ();
	$flag = 0;

	($seq_lib, $seq_ID, $blank, $seq_count) = split(/\;/, $seq);

	$x = 0;
	while ($x < scalar(@{$internal_alignments{$seq}})) {
		if ($internal_alignment_scores{$seq}[$x] <= $max_alignment_score) {
			push(@int_aligns, $internal_alignments{$seq}[$x]);
		} elsif ($internal_alignment_scores{$seq}[$x] < $max_alignment_score*$divergence_factor) {
			$flag = 1;
		}
		$x++;
	}
	if (scalar(@int_aligns) > $max_internal_alignments 
	|| scalar(@int_aligns) < $min_internal_alignments) { $flag = 1; }

	$x = 0;
	while ($x < scalar(@{$external_alignments{$seq}})) {
		if ($external_alignment_scores{$seq}[$x] <= $max_alignment_score) {
			push(@ext_aligns, $external_alignments{$seq}[$x]);
		} elsif ($external_alignment_scores{$seq}[$x] < $max_alignment_score*$divergence_factor) {
			$flag = 1;
		}
		$x++;
	}
	if (scalar(@ext_aligns) > $max_external_alignments
	|| scalar(@ext_aligns) < $min_external_alignments) { $flag = 1; }

	if (scalar(@int_aligns)+scalar(@ext_aligns) > $max_total_alignments
	|| scalar(@int_aligns)+scalar(@ext_aligns) < $min_total_alignments) { $flag = 1; }

	if ($flag != 1) {
		@aligns = ($seq, @int_aligns, @ext_aligns);
		@aligns = sort(@aligns);
		return @aligns;
	}
}

