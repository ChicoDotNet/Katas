use v5.20;
use strict;
use warnings;
use utf8;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec;
use IPC::Open3;
use Symbol qw(gensym);
use FindBin;

my $dir = tempdir(CLEANUP => 1);
my $a = File::Spec->catfile($dir, 'first.txt');
my $b = File::Spec->catfile($dir, 'second.txt');
for my $pair ([$a, "alpha\nBETA\na.b\n\nneedle\nneedle\n"], [$b, "other\nALPHA\na?b\n\n"]) {
    open my $fh, '>:raw', $pair->[0] or die $!;
    print {$fh} $pair->[1];
    close $fh;
}
my $impl = $ENV{KATA_GREP_IMPL} // "$FindBin::Bin/../src/grep.pl";
sub execute {
    my (@args) = @_;
    my $err = gensym;
    my $pid = open3(my $in, my $out, $err, $^X, $impl, @args);
    close $in;
    local $/;
    my $stdout = <$out> // '';
    my $stderr = <$err> // '';
    waitpid($pid, 0);
    return ($stdout, $? >> 8, $stderr);
}
sub expect {
    my ($label, $expected, @args) = @_;
    my ($out, $status) = execute(@args);
    is($status, 0, "$label exit");
    is($out, $expected, "$label output");
}
expect('fixed substring', "alpha\n", 'alp', $a);
my $unicode_file = File::Spec->catfile($dir, 'unicode.txt');
open my $unicode_fh, '>:raw', $unicode_file or die $!;
print {$unicode_fh} "caf\xC3\xA9\n";
close $unicode_fh;
expect('UTF-8 pattern decoded', "caf\xC3\xA9\n", "caf\xC3\xA9", $unicode_file);
expect('regex punctuation is literal', "a.b\n", 'a.b', $a);
my $dash_file = File::Spec->catfile($dir, 'dash.txt');
open my $dash_fh, '>:raw', $dash_file or die $!;
print {$dash_fh} "-x\n-needle\n";
close $dash_fh;
expect('dash-prefixed literal pattern after terminator', "-x\n", '--', '-x', $dash_file);
expect('case insensitive', "alpha\n", '-i', 'ALPHA', $a);
expect('exact only', "a.b\n", '-x', 'a.b', $a);
expect('invert', "BETA\na.b\n\nneedle\nneedle\n", '-v', 'alpha', $a);
expect('numbering', "5:needle\n6:needle\n", '-n', 'needle', $a);
expect('multi file', "$a:alpha\n$b:ALPHA\n", '-i', 'alpha', $a, $b);
expect('multi file numbering', "$a:1:alpha\n$b:2:ALPHA\n", '-n', '-i', 'alpha', $a, $b);
expect('file names only', "$a\n$b\n", '-l', '-i', 'alpha', $a, $b);
expect('file names override numbering', "$a\n$b\n", '-n', '-l', '-i', 'alpha', $a, $b);
expect('empty pattern', "alpha\nBETA\na.b\n\nneedle\nneedle\n", '', $a);
expect('empty exact pattern', "\n", '-x', '', $a);
my $unterminated = File::Spec->catfile($dir, 'unterminated.txt');
open my $noeol, '>:raw', $unterminated or die $!;
print {$noeol} 'alpha';
close $noeol;
expect('final line without LF', "alpha\n", 'alpha', $unterminated);
expect('no match', '', 'unfindable', $a);
expect('file order and duplicates', "$b:ALPHA\n$a:alpha\n$b:ALPHA\n", '-i', 'alpha', $b, $a, $b);
my ($missing_out, $missing_status) = execute('alpha', $a, "$dir/missing.txt");
is($missing_status, 2, 'missing file exit 2');
is($missing_out, '', 'missing file does not leak partial output');
my ($bad_out, $bad_status) = execute('-z', 'alpha', $a);
is($bad_status, 2, 'unknown flag rejected');
is($bad_out, '', 'unknown flag no output');
done_testing();
