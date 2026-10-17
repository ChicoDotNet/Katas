use strict;use warnings;use Test::More;use FindBin;use lib "$FindBin::Bin/../lib";use Sgf;
sub tree{Sgf::parse(shift)}
sub node{my($properties,$children)=@_;return {properties=>$properties,children=>$children||[]}}
my $empty=node({});
is_deeply(tree('(;)' ),$empty,'empty node');
is_deeply(tree('(;A[one])'),node({A=>['one']}),'single property');
is_deeply(tree('(;A[one][two])'),node({A=>['one','two']}),'multiple values');
is_deeply(tree('(;A[x]A[y])'),node({A=>['x','y']}),'duplicate property combined');
is_deeply(tree('(;C[hello\] world])'),node({C=>['hello] world']}),'escaped closing bracket');
is_deeply(tree('(;C[one\\\\two])'),node({C=>['one\\two']}),'escaped backslash');
is_deeply(tree("(;C[a\\\nb])"),node({C=>['ab']}),'escaped physical line break');
is_deeply(tree('(;A[1];B[2])'),node({A=>['1']},[node({B=>['2']})]),'main sequence chain');
is_deeply(tree('(;A[1](;B[2])(;C[3]))'),node({A=>['1']},[node({B=>['2']}),node({C=>['3']})]),'two variations');
is_deeply(tree('(;A[1];B[2](;C[3])(;D[4]))'),node({A=>['1']},[node({B=>['2']},[node({C=>['3']}),node({D=>['4']})])]),'variations attach to tail');
ok(!defined(tree('(;A)')),'property requires brackets');
ok(!defined(tree('(;C[unfinished)')),'unterminated bracket rejected');
ok(!defined(tree('(;)(;)')),'only one tree accepted');
ok(!defined(tree('(;)garbage')),'trailing input rejected');
ok(!defined(tree('()')),'no empty game tree');
done_testing();
