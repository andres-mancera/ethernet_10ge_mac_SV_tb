#!/bin/perl

my @logfiles = `find ../ -name vcs.log`;
my $logcount = $#logfiles+1;
if ( $logcount==0 ) {
  die "Cannot find VCS log files, report cannot be generated!\n";
}
my $pass_total, $fail_total, $other_total, $test_total = 0;
my @results_array;

foreach my $logfile (@logfiles) {
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
    push (@results_array, "  PASSED  (Seed=$test_seed)\t ==>   $logfile");
    $pass_total++;
  } elsif ($fail){
    push (@results_array, "  FAILED  (Seed=$test_seed)\t ==>   $logfile");
    $fail_total++;
  } else {
    push (@results_array, "  UNKNOWN (Seed=$test_seed)\t ==>   $logfile");
    $other_total++;
  }
  $test_total++;
}

my $pass_percent  = ($pass_total/$test_total)*100;
my $fail_percent  = ($fail_total/$test_total)*100;
my $other_percent = ($other_total/$test_total)*100;

printf ("\n");
printf ("===============================================================================\n");
printf ("                             REGRESSION SUMMARY\n");
printf ("===============================================================================\n");
printf ("      TESTCASES THAT PASSED         :  %d [%d\%]\n", $pass_total, $pass_percent);
printf ("      TESTCASES THAT FAILED         :  %d [%d\%]\n", $fail_total, $fail_percent);
printf ("      TESTCASES WITH UNKNOWN STATUS :  %d [%d\%]\n", $other_total, $other_percent);
printf ("      TOTAL NUMBER OF TESTCASES     :  %d\n", $test_total);
printf ("===============================================================================\n");
printf ("\n");
foreach (@results_array) {
  print ($_);
}
printf ("\n");
printf ("===============================================================================\n");
printf ("\n");
