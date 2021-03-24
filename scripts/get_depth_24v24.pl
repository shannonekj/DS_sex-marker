#!/usr/bin/perl
# File: get_depth_24v24.pl
# Author: Shannon E.K. Joslin
# Date: 23 March 2021
# Usage: perl get_depth_24v24.pl <in_file> <out_file>
# Use: will compare the first 24 individuals' depth stats to a second set of individuals' depth stats.
# Notes:  * eventually should make this take in n individuals and compare to x individuals (so can enter numbers at the cmdlne)

use strict;
use warnings;

die "Usage: get_depth.pl <infile> <outfile>\n" if (@ARGV != 2);
print "Getting depths from: $ARGV[0]\n";

my ($file) = $ARGV[0];
open(my $in, "< $file");
my ($outfile) = $ARGV[1];
open(my $out, "> $outfile") or die "error creating $outfile. $!";
open(my $log, "> $outfile.fmt") or die "error creating $outfile.fmt. $!";

while (<$in>) {
    chomp;
    my @array = split(" ", $_);
    my $chromosome = $array[0];
    my $position = $array[1];
    my @depth_M = @array[2..25];
    my @depth_F = @array[24..$#array-1];
    my $total_coverage_M = eval join '+', @depth_M;
    my $total_coverage_F = eval join '+', @depth_F;

    my $mean_coverage_M;
    my $n_ind_M = 0;
    for (my $i = 0; $i <= 23; $i++) {
        if($depth_M[$i] > 0 ){
            $n_ind_M = $n_ind_M + 1;
        }
    }
    if( $n_ind_M != 0) {
        $mean_coverage_M = $total_coverage_M / $n_ind_M;
        }else{
        $mean_coverage_M = 0;
    }

    my $mean_coverage_F;
    my $n_ind_F = 0;
    for (my $y = 0; $y <= 23; $y++) {
        if($depth_F[$y] > 0 ){
            $n_ind_F = $n_ind_F + 1;
        }
    }
    if( $n_ind_F != 0) {
        $mean_coverage_F = $total_coverage_F / $n_ind_F;
        }else{
        $mean_coverage_F = 0;
    }
    my $abs_diff = abs($n_ind_M-$n_ind_F); 
#    print "$chromosome\t$position ";
#    print "[@depth]\t$total_coverage\n";
#    print "Num Ind: $n_ind\nMean Coverage: $mean_coverage\n";
    print $out "$chromosome\t$position\t$n_ind_M\t$total_coverage_M\t$mean_coverage_M\t$n_ind_F\t$total_coverage_F\t$mean_coverage_F\t$abs_diff\n";
}

print $log "Format of $outfile is: CHROMOSOME\tPOSITION\tM_IND_W_COV\tM_TOTAL_COV\tM_MEAN_COV\tF_IND_W_COV\tF_TOTAL_COV\tF_MEAN_COV\tCOV_DIFF\n";

close($in);
close($out);
close($log);

