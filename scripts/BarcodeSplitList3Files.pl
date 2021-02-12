#!/usr/bin/perl

if ($#ARGV == 4) {
	$fileR1 = $ARGV[0];
	$fileR2 = $ARGV[1];
	$fileR3 = $ARGV[2];
	$barcode = $ARGV[3];
	$prefix = $ARGV[4];
} else {
	die;	
}

@commas = split(/\,/, $barcode);

$x=0;
while ($x <= $#commas) {

	$hashR1{$commas[$x]} = $prefix . "_R1_" . $commas[$x] . ".fastq";
	$filenameR1 = $hashR1{$commas[$x]};
	open($filenameR1, ">$filenameR1") or die;

	$hashR2{$commas[$x]} = $prefix . "_R2_" . $commas[$x] . ".fastq";
        $filenameR2 = $hashR2{$commas[$x]};
        open($filenameR2, ">$filenameR2") or die;

	$hashR3{$commas[$x]} = $prefix . "_R3_" . $commas[$x] . ".fastq";
        $filenameR3 = $hashR3{$commas[$x]};
        open($filenameR3, ">$filenameR3") or die;

	$x++;
}


open(FILER1, "<$fileR1") or die;
open(FILER2, "<$fileR2") or die;
open(FILER3, "<$fileR3") or die;


while (<FILER1>) {

	$R1_l1 = $_;
	$R1_l2 = <FILER1>;
	$R1_l3 = <FILER1>;
	$R1_l4 = <FILER1>;

        $R2_l1 = <FILER2>;
        $R2_l2 = <FILER2>;
        $R2_l3 = <FILER2>;
        $R2_l4 = <FILER2>;

        $R3_l1 = <FILER3>;
        $R3_l2 = <FILER3>;
        $R3_l3 = <FILER3>;
        $R3_l4 = <FILER3>;


	$bc = substr($R2_l2,0,6);
	
	if ($hashR1{$bc} ne "")  {
	
		$F1 = $hashR1{$bc}; $F2 = $hashR2{$bc}; $F3 = $hashR3{$bc};
		print $F1 $R1_l1 . $R1_l2 . $R1_l3 . $R1_l4;
		print $F2 $R2_l1 . $R2_l2 . $R2_l3 . $R2_l4;
		print $F3 $R3_l1 . $R3_l2 . $R3_l3 . $R3_l4;

	}

}
close FILER1; close FILER2; close FILER3;

$x=0;
while ($x <= $#commas) {
        $F1 = $hashR1{$commas[$x]}; $F2 = $hashR2{$commas[$x]}; $F3 = $hashR3{$commas[$x]};
        close($F1); close($F2); close($F3);
        $x++;
}




