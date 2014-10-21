#!/usr/bin/perl

use strict;
use warnings;

#month day time machine service message


# read from stdin
while(<>){
    chomp;
    my $line = $_;
    my ($not_message, $message) = split ': ', $line, 2;

    # skip lines with blank messages
    next if $message =~ m/^\s*$/;

    # get rid of bracketed numbers
    $not_message =~ s/\[\d+\]//;

    my ($month, $day, $time, $machine, $service) = split " ", $not_message;

    # print "Month: $month\n";
    # print "Day: $day\n";
    # print "Time: $time\n";
    # print "Machine: $machine\n";
    # print "Service: $service\n\n";

    print join("\t", $month, $day, $time, $machine, $service, $message) . "\n";
}

