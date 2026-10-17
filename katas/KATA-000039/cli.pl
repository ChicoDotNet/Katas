#!/usr/bin/env perl
# SPDX-License-Identifier: MIT
use strict;use warnings;use FindBin;use lib "$FindBin::Bin/lib";use JSON::PP;use Sgf;
local $/;
my $texts=decode_json(<STDIN>);
die "must be a list" unless ref($texts) eq 'ARRAY';
my @out=map {my $node=Sgf::parse($_);$node?{ok=>JSON::PP::true,root=>$node}:{ok=>JSON::PP::false}} @$texts;
print encode_json(\@out),"\n";
