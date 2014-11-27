#!/bin/perl

printf ("\n");
printf ("=============================\n");
printf ("Generating Regression Summary\n");
printf ("=============================\n\n");

my @logfiles = `find ../ -name vcs.log`;
my $logcount = $#logfiles+1;
if ( $logcount==0 ) {
  die "Cannot find VCS log files, report cannot be generated!\n";
}
my $pass_total, $fail_total, $other_total, $test_total = 0;

foreach my $logfile (@logfiles){
  my $pass = `egrep \"TESTCASE:.*PASSED\" $logfile`; 
  my $fail = `egrep \"TESTCASE:.*FAILED|ASSERTION FAILED\" $logfile`;
  my $seed = `egrep \"automatic random seed used\" $logfile`;
  my $test_seed;
  if ( $seed =~ /NOTE: automatic random seed used:\s*(\d+)/ ) {
    $test_seed = $1;
  }
  else {
    $test_seed = "unknown";
  }
  if($pass){
    print ("  PASSED  (Seed=$test_seed)\t ==>   $logfile");
    $pass_total++;
  } elsif ($fail){
    print ("  FAILED  (Seed=$test_seed)\t ==>   $logfile");
    $fail_total++;
  } else {
    print ("  UNKNOWN (Seed=$test_seed)\t ==>   $logfile");
    $other_total++;
  }
  $test_total++;
}

my $pass_percent  = ($pass_total/$test_total)*100;
my $fail_percent  = ($fail_total/$test_total)*100;
my $other_percent = ($other_total/$test_total)*100;

printf ("\n");
printf ("===============================================================================\n");
printf ("REGRESSION SUMMARY => PASS: %d[%d\%], FAIL: %d[%d\%], UNKNOWN: %d[%d\%], TOTAL: %d\n", $pass_total, $pass_percent, $fail_total, $fail_percent, $other_total, $other_percent, $test_total);
printf ("===============================================================================\n\n");
