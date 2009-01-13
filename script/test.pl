use strict;
use Data::Dump 'dump';
use XML::Parser ();
use feature ':5.10';

# FIXME: Don't make a real XML parser
my $xml = XML::Parser->new(
    Handlers => {
        Start => \&handle_start,
        Char  => \&handle_char,
        End   => \&handle_end,
    },
);


if (not -t STDIN) {
    # Read from STDIN
    $xml->parse(*STDIN);
} elsif ($ARGV[0] and -f $ARGV[0]) {
    $xml->parsefile($ARGV[0]);
} else {
    help();
}

my $xml_in_trkpt = undef;
my $xml_in_trkpt_data = undef;
my $xml_in_trkpt_in_subelement = undef;

sub handle_start
{
    my ($parser, $element, %attr) = @_;


    if ($xml_in_trkpt) {
        return unless $element eq 'ele' or $element eq 'time';

        $xml_in_trkpt_in_subelement = $element;
    } else {
        return unless $element eq 'trkpt';

        # We are now within <trkpt>
        $xml_in_trkpt = 1;

        # Make a record of lat/lon
        $xml_in_trkpt_data->{lat} = $attr{lat};
        $xml_in_trkpt_data->{lon} = $attr{lon};
    }
}

sub handle_char
{
    my ($parser, $str) = @_;

    return unless $xml_in_trkpt_in_subelement;

    if ($xml_in_trkpt_in_subelement eq 'ele') {
        $xml_in_trkpt_data->{ele} = $str;
    } elsif ($xml_in_trkpt_in_subelement eq 'time') {
        $xml_in_trkpt_data->{time} = $str;
    } else {
        die "Internal error";
    }
}

sub handle_end
{
    my ($parser, $element) = @_;

    return unless $element eq 'trkpt'
                  or $element eq 'ele'
                  or $element eq 'time';

    if ($element eq 'trkpt') {
        say dump($xml_in_trkpt_data);

        # Reset all stored data
        $xml_in_trkpt = $xml_in_trkpt_data = undef;
    } elsif ($element eq 'ele' or $element eq 'time') {
        $xml_in_trkpt_in_subelement = undef;
    } else {
        die "Internal error";
    }
}
