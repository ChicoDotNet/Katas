#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin;
use Encode qw(decode FB_CROAK);
use lib $FindBin::Bin;
my $source = $ENV{OHCE_SOURCE} // 'Ohce';
die "invalid module\n" unless $source =~ /\A(?:Ohce|OhceRed|OhceMutant)\z/;
require "$source.pm";
my $name;
my $hour;
while (@ARGV) {
    my $option = shift @ARGV;
    if ($option eq '--name') { die "duplicate name\n" if defined $name; die "missing name\n" unless @ARGV; $name = shift @ARGV; }
    elsif ($option eq '--hour') { die "duplicate hour\n" if defined $hour; die "missing hour\n" unless @ARGV; $hour = shift @ARGV; }
    else { die "unknown option\n"; }
}
$name = decode('UTF-8', $name, FB_CROAK) if defined $name;
$hour = (localtime)[2] unless defined $hour;
# Read raw lines and reject malformed UTF-8 rather than silently replacing bytes.
binmode STDIN, ':raw';
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';
my $greeting = $source->can('greeting')->($name, $hour);
print "$greeting\n";
while (defined(my $raw_line = <STDIN>)) {
    my $line = decode('UTF-8', $raw_line, FB_CROAK);
    $line =~ s/\r?\n\z//;
    if ($line eq 'Stop!') { print "Adios $name\n"; last; }
    my $reverse = $source->can('reverse_graphemes')->($line);
    print "$reverse\n";
    print "¡Bonita palabra!\n" if length($line) && $line eq $reverse;
}
