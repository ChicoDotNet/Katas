package OhceRed;
use strict;
use warnings;
use utf8;
use Exporter 'import';
our @EXPORT_OK = qw(greeting reverse_graphemes session);
sub greeting { my ($name, $hour) = @_; return "¡Buenas noches $name!"; }
sub reverse_graphemes { return $_[0]; }
sub session { my ($name, $hour, @messages) = @_; return [ greeting($name,$hour), @messages ]; }
1;
