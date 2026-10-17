# SPDX-License-Identifier: MIT
package Sgf;
use strict;use warnings;

# Bounded, independently written SGF-subset tree parser.
sub parse {
 my ($input)=@_;
 return undef if !defined($input)||length($input)>8192;
 return undef if $ENV{KATA_RED}; # behaviorally incorrect but loadable RED
 my $p=bless {text=>$input,at=>0,n=>0},__PACKAGE__;
 my $result=eval {$p->_tree(0)};
 return undef if $@||!$result;
 $p->_ws;
 return undef if $p->{at}!=length($input);
 return $result;
}
sub _peek {my($self)=@_;return substr($self->{text},$self->{at},1)}
sub _take {my($self)=@_;return substr($self->{text},$self->{at}++,1)}
sub _ws {my($self)=@_;$self->{at}++ while $self->{at}<length($self->{text})&&$self->_peek=~/\s/}
sub _expect {my($self,$char)=@_;die 'syntax' unless $self->_peek eq $char;$self->_take}
sub _tree {
 my($self,$depth)=@_;die 'depth' if $depth>24;
 $self->_ws;$self->_expect('(');$self->_ws;
 die 'empty tree' unless $self->_peek eq ';';
 my($root,$tail);
 while($self->_peek eq ';'){
  $self->_take;$self->{n}++;die 'node limit' if $self->{n}>300;
  my $node={properties=>{},children=>[]};
  if(!$root){$root=$node}else{push @{$tail->{children}},$node}
  $tail=$node;$self->_ws;
  while($self->_peek=~/[A-Z]/){
   my $key='';
   $key.=$self->_take while $self->_peek=~/[A-Z]/;
   $self->_ws;
   die 'missing property value' unless $self->_peek eq '[';
   my @values;
   while($self->_peek eq '['){push @values,$self->_value;$self->_ws}
   push @{$node->{properties}{$key}},@values;
  }
  $self->_ws;
 }
 while($self->_peek eq '('){push @{$tail->{children}},$self->_tree($depth+1);$self->_ws}
 $self->_expect(')');return $root;
}
sub _value {
 my($self)=@_;$self->_expect('[');my $value='';
 while($self->{at}<length($self->{text})){
  my $c=$self->_take;
  if($c eq ']'){return $value}
  if($c eq '\\'){
   die 'truncated escape' if $self->{at}>=length($self->{text});
   my $escaped=$self->_take;
   if($escaped eq "\r" && $self->_peek eq "\n"){$self->_take;next}
   next if $escaped eq "\n"||$escaped eq "\r";
   $value.=$escaped;
  }else{$value.=$c}
 }
 die 'unclosed bracket';
}
1;
