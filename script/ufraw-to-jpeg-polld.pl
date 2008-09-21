#!/usr/bin/env perl
use strict;
use warnings;

while (sleep 10) {
    my @ufraw = glob "*.ufraw";

    for my $ufraw (@ufraw) {
        my ($base) = $ufraw =~ m[^(.*)\.ufraw$];
        my $jpeg = $base . '.jpg';
        my $cr2  = $base . '.cr2';

        # JPEG already exists
        next if -f $jpeg;

        warn "$jpeg does not exist, creating";
        my $ufraw_src = slurp($ufraw);

        if ($ufraw_src =~ m[<CreateID>2</CreateID>]) {
            # Only
            my $cmd = "$^X -pi -e 's[<CreateID>2</CreateID>][<CreateID>1</CreateID>]' $ufraw";
            warn "Running `$cmd'";
            system $cmd and die $!;
        } elsif ($ufraw_src =~ m[<CreateID>1</CreateID>]) {
            # Already fine
        } else {
            die "Danger will robinson!";
        }

        my $cmd = "nice -n 1 ufraw-batch --conf=$ufraw $cr2";

        warn "Creating JPEG with `$cmd'";

        system $cmd and die $!;
    }

    warn "Sleeping";
}

sub slurp
{
    my ($file) = @_;
    do {
        local (@ARGV, $/) = $file;
        scalar <>;
    }
}
