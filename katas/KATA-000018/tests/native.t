use strict;
use warnings;
use utf8;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../src";
my $module = $ENV{OHCE_IMPL} // 'Ohce';
die 'invalid module' unless $module =~ /\A(?:Ohce|OhceRed)\z/;
eval "require $module; 1" or die $@;
my $greet = $module->can('greeting');
my $reverse = $module->can('reverse_graphemes');
my $session = $module->can('session');
for my $h (0..23) {
    my $kind = ($h < 6 || $h >= 20) ? 'noches' : ($h < 12 ? 'días' : 'tardes');
    like($greet->('Ana', $h), qr/\Q$kind\E/, "hour $h boundary");
}
is($reverse->('hola'), 'aloh', 'basic reversal');
is($reverse->('oto'), 'oto', 'palindrome');
is($reverse->("a\x{301}b"), "ba\x{301}", 'Unicode grapheme cluster reversal');
is($reverse->(''), '', 'empty reversal');
is_deeply($session->('Ana', 12, 'hola', 'oto', 'Stop!', 'ignored'),
    ['¡Buenas tardes Ana!', 'aloh', 'oto', '¡Bonita palabra!', 'Adios Ana'], 'stream session stops');
is_deeply($session->('Ana', 6, '', 'Stop!'),
    ['¡Buenos días Ana!', '', 'Adios Ana'], 'empty input not a palindrome');
for my $bad (-1, 24, '06', 'foo') {
    my $ok = eval { $greet->('Ana', $bad); 1 };
    ok(!$ok, "reject invalid hour $bad");
}
for my $bad ('', undef) {
    my $ok = eval { $greet->($bad, 12); 1 };
    ok(!$ok, 'reject missing name');
}
done_testing();
