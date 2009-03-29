#!/usr/bin/env perl
use strict;
use warnings;
use feature ':5.10';

my $directory = $ARGV[0] // '.';

opendir my $dir, $directory or die "Can't open dir `$directory': $!";
my @file = sort grep { not /^\.{1,2}$/ } readdir $dir;
closedir $dir;

die "`out' directory already exists" if -d 'out';
mkdir 'out' or die "Can't mkdir(out): $!";

my @jpeg = grep { -f and /\.jpg$/i} @file;

# Go through all the JPEG files and find the equivalent CR2 and UFRAW
# files, rar them up and append them to the JPEG
for my $jpeg (@jpeg) {
    my ($name, $ext) = split /\./, $jpeg;

    my @append = grep { /^$name\.(?i:cr2|ufraw)$/ } @file;

    if (!@append) {
        say "No cr2 or ufraw files for $jpeg, skipping";
        next;
    }

    $, = ",";
    say "$jpeg -> append @append";

    my $cmd;

    $cmd = "rar a $name.rar @append";
    system $cmd and die "Command `$cmd' failed with code `$?'";

    $cmd = "cat $jpeg $name.rar >> $jpeg.new";
    system $cmd and die "Command `$cmd' failed with code `$?'";

    $cmd = "rm $name.rar";
    system $cmd and die "Command `$cmd' failed with code `$?'";

    $cmd = "mv $jpeg.new out/$jpeg";
    system $cmd and die "Command `$cmd' failed with code `$?'";
}


