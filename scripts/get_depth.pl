#!/usr/bin/perl
# File: get_depth.pl
# Author: Shannon E.K. Joslin
# Date: 23 March 2021
# Usage: perl get_depth.pl <in_file> <out_file>
# Use: will get number of individuals with sequence coverage and the mean coverage for all individuals in a file
# Notes: eventually should add in total coverage
use strict;
use warnings;

die "Usage: get_depth.pl <infile> <outfile>\n" if (@ARGV != 2);
print "Getting depths from: $ARGV[0]\n";

my ($file) = $ARGV[0];
open(my $in, "< $file");
my ($outfile) = $ARGV[1];
open(my $out, "> $outfile") or die "error creating $outfile. $!";

while (<$in>) {
    chomp;
    my @array = split(" ", $_);
    my $chromosome = $array[0];
    my $position = $array[1];
    my @depth = @array[2..$#array-1];
    my $total_coverage = eval join '+', @depth;
    my $mean_coverage;
    my $n_ind = 0;
    for (my $i = 0; $i <= 23; $i++) {
        if($depth[$i] > 0 ){
            $n_ind = $n_ind + 1;
        }
    }
    if( $n_ind != 0) {
        $mean_coverage = $total_coverage / $n_ind;
        }else{
        $mean_coverage = 0;
    }
#    print "$chromosome\t$position ";
#    print "[@depth]\t$total_coverage\n";
#    print "Num Ind: $n_ind\nMean Coverage: $mean_coverage\n";
    print $out "$chromosome\t$position\t$n_ind\t$mean_coverage\n";
}
close($in);
close($out);


### (RE)LEARNING PERL

#my @file = <>;
#print "$file[0]";

# this prints each line of a file
#while (<>) {
#    print;
#}

# turns into uppercase
#my ($file) = @ARGV;
#open(my $in, "< $file");
#while (my $line = <$in>) {
#    $line = uc($line);
#    my @first = qw(print($line));
#    print "$line";
#    print "$first[0]\n";
#}
#close($in);

# prints one line....
#open(my $in, "< $file");
#my $locus;
#while (my @line = <$in>) {
#    $locus = $line[1];
#    print $locus;
#}
#close($in)


# prints number of lines and the number of characters
#my $lines = 0;
#my $characters = 0;
#while (my $line = <>) {
#    $lines++;
#    $characters += length($line);
#}
#
#print "$lines\t$characters\n";
