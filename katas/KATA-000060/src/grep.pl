#!/usr/bin/env perl
use v5.20;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use Encode qw(decode FB_CROAK);

# Original fixed-string grep; no external starter or test data imported.
sub ascii_fold {
    my ($s) = @_;
    $s =~ tr/A-Z/a-z/;
    return $s;
}

sub fail_usage {
    my ($reason) = @_;
    print STDERR "grep kata: $reason\n";
    exit 2;
}

# Perl does not automatically decode UTF-8 command-line arguments on Unix.
# Decode explicitly to compare them with decoded file contents.
my @decoded;
for my $arg (@ARGV) {
    my $value = eval { decode('UTF-8', $arg, FB_CROAK) };
    fail_usage('invalid UTF-8 argument') if $@;
    push @decoded, $value;
}
@ARGV = @decoded;

my %flags;
while (@ARGV && $ARGV[0] =~ /^-[nilvx]$/) {
    my $flag = shift @ARGV;
    $flags{$flag} = 1;
}
my $literal_pattern = 0;
if (@ARGV && $ARGV[0] eq '--') {
    shift @ARGV;
    $literal_pattern = 1;
}
fail_usage('pattern and at least one file required') unless @ARGV >= 2;
my $pattern = shift @ARGV;
fail_usage('unknown option') if !$literal_pattern && $pattern =~ /^-/ && $pattern ne '-';
my @files = @ARGV;

# Validate all inputs before emitting any result; failure is atomic.
for my $file (@files) {
    fail_usage("cannot read file: $file") unless -f $file && -r $file;
}
my $multi = @files > 1;
my $folded_pattern = $flags{'-i'} ? ascii_fold($pattern) : $pattern;
for my $file (@files) {
    open my $fh, '<:encoding(UTF-8)', $file or fail_usage("cannot open file: $file");
    my $line_no = 0;
    while (defined(my $line = <$fh>)) {
        ++$line_no;
        chomp $line;
        my $haystack = $flags{'-i'} ? ascii_fold($line) : $line;
        my $matched = $flags{'-x'}
            ? ($haystack eq $folded_pattern)
            : (index($haystack, $folded_pattern) >= 0);
        $matched = !$matched if $flags{'-v'};
        next unless $matched;
        if ($flags{'-l'}) {
            print "$file\n";
            last;
        }
        my $prefix = ($multi ? "$file:" : '') . ($flags{'-n'} ? "$line_no:" : '');
        print "$prefix$line\n";
    }
    close $fh or fail_usage("cannot close file: $file");
}
