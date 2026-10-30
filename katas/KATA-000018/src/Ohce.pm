package Ohce;
use strict;
use warnings;
use utf8;
use Exporter 'import';
our @EXPORT_OK = qw(greeting reverse_graphemes session);

sub greeting {
    my ($name, $hour) = @_;
    die "invalid name\n" unless defined($name) && length($name);
    die "invalid hour\n" unless defined($hour) && $hour =~ /\A(?:0|[1-9][0-9]?)\z/ && $hour <= 23;
    return "¡Buenas noches $name!" if $hour < 6 || $hour >= 20;
    return "¡Buenos días $name!" if $hour < 12;
    return "¡Buenas tardes $name!";
}

sub reverse_graphemes {
    my ($message) = @_;
    die "undefined message\n" unless defined $message;
    my @clusters = $message =~ /\X/g;
    return join '', reverse @clusters;
}

# A pure session model for native behavioral tests; the real CLI streams lines.
sub session {
    my ($name, $hour, @messages) = @_;
    my @output = (greeting($name, $hour));
    for my $message (@messages) {
        if ($message eq 'Stop!') {
            push @output, "Adios $name";
            last;
        }
        my $reversed = reverse_graphemes($message);
        push @output, $reversed;
        push @output, '¡Bonita palabra!' if length($message) && $reversed eq $message;
    }
    return \@output;
}
1;
