use strict;
use File::Slurp qw(slurp);
use Date::Parse qw(str2time);

my %data;
my $gpx = shift;

my $cont = slurp($gpx);

# FIXME: Make a real XML parser
my $rx = qr[
               <trkpt\ lat="(.*?)"\ lon="(.*?)"> \s*
               <ele>(.*?)</ele> \s*
               <time>(.*?)</time> \s*
               </trkpt>
       ]xs;
while ($cont =~ /$rx/g) {
    my $lat  = $1;
    my $lon  = $2;
    my $ele  = $3;
    my $date = $4;
    my $time = str2time($date);
    $data{$time} = {
        lat => $lat,
        lon => $lon,
        ele => $ele,
        date => $date,
    };
}
