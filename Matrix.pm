#!/usr/local/ls6/perl/bin/perl
#                              -*- Mode: Perl -*- 
# Matrix.pm -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Tue Oct 24 18:34:08 1995
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Wed Oct 25 11:07:07 1995
# Language        : Perl
# Update Count    : 134
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1995, Universitšt Dortmund, all rights reserved.
# 
# $Locker: pfeifer $
# $Log: Matrix.pm,v $
# Revision 1.1  1995/10/25  09:48:39  pfeifer
# Initial revision
#
# 

=head1 NAME

Math::Matrix

=head1 METHODS

=head2 new

Constructor arguments are a list of references to arrays of the same
length.  The arrays are copied. The method returns B<undef> in case of
error.

        $a = new Math::Matrix ([rand,rand,rand], 
                               [rand,rand,rand], 
                               [rand,rand,rand]);

=head2 concat

Concatenates two matrices of same row count. The result is a new
matrix or B<undef> in case of error.

        $b = new Math::Matrix ([rand],[rand],[rand]);
        $c = $a->concat($b);

=head2 transpose

Returns the transposed matrix. This is the matrix where colums and
rows of the argument matrix are swaped.

=head2 multiply

Multiplies two matrices where the length of the rows in the first
matrix is the same as the length of the columns in the second
matrix. Returns the product or B<undef> in case of error.

=head2 solve

Solves a equation system given by the matrix. The number of colums
must be greater than the number of rows. If variables are dependent
from each other, the second and all further of the dependent
coefficients are 0. This means the method can handle such systems. The
method returns a matrix containing the solutions in its columns or
B<undef> in case of error.

=head2 print

Prints the matrix on STDOUT. If the method has additional parameters,
these are printed before the matrix is printed.

=head1 EXAMPLE

        use Math::Matrix;

        srand(time);
        $a = new Math::Matrix ([rand,rand,rand], 
                         [rand,rand,rand], 
                         [rand,rand,rand]);
        $x = new Math::Matrix ([rand,rand,rand]);
        $a->print("A\n");
        $E = $a->concat($x->transpose);
        $E->print("Equation system\n");
        $s = $E->solve;
        $s->print("Solutions s\n");
        $a->multiply($s)->print("A*s\n");

=head1 AUTHOR

Ulrich Pfeifer <pfeifer@ls6.informatik.uni-dortmund.de>

=cut

package Math::Matrix;

$RCS_Id = '$Id: Matrix.pm,v 1.1 1995/10/25 09:48:39 pfeifer Exp pfeifer $ ';
($my_name, $my_version) = $RCS_Id =~ /: (.+).pm,v ([\d.]+)/;

sub version {
    return "Math::$my_name $my_version";
}

sub new {
    my $type = shift;
    my $self = [];
    my $len = length(@{$_[0]});
    for (@_) {
        return undef if length(@{$_}) != $len;
        push(@{$self}, [@{$_}]);
    }
    bless $self, $type;
}

sub concat {
    my $self = shift;
    my $other = shift;
    my $result = new Math::Matrix (@{$self});
    
    return undef if length(@{$self}) != length(@{$other});
    for $i (0 .. $#{$self}) {	
	push @{$result->[$i]}, @{$other->[$i]};
    }
    $result;
}

sub transpose {
    my $self = shift;
    my @result;
    my $m;

    for $col (@{$self->[0]}) {
        push @result, [];
    }
    for $row (@{$self}) {
        $m=0;
        for $col (@{$row}) {
            push(@{$result[$m++]}, $col);
        }
    }
    new Math::Matrix @result;
}

sub vekpro {
    my($a, $b) = @_;
    my $result;

    for $i (0 .. $#{$a}) {
        $result += $a->[$i] * $b->[$i];
    }
    $result;
}
                  
sub multiply {
    my $self  = shift;
    my $other = shift->transpose;
    my @result;
    my $m;
    
    return undef if $#{$self->[0]} != $#{$other->[0]};
    for $row (@{$self}) {
        my $rescol = [];
	for $col (@{$other}) {
            push(@{$rescol}, vekpro($row,$col));
        }
        push(@result, $rescol);
    }
    new Math::Matrix @result;
}

$eps = 0.00001;

sub solve {
    my $m    = new Math::Matrix (@{$_[0]});
    my $mr   = $#{$m};
    my $mc   = $#{$m->[0]};
    my $f;
    my $try;

    return undef if $mc <= $mr;
    ROW: for($i = 0; $i <= $mr; $i++) {
	$try=$i;
	# make diagonal element nonzero if possible
	while (abs($m->[$i]->[$i]) < $eps) {
	    last ROW if $try++ > $mr;
	    my $row = splice(@{$m},$i,1);
	    push(@{$m}, $row);
	}

	# normalize row
	$f = $m->[$i]->[$i];
	for($k = 0; $k <= $mc; $k++) {
            $m->[$i]->[$k] /= $f;
	}
	# subtract multiple of designated row from other rows
        for($j = 0; $j <= $mr; $j++) {
	    next if $i == $j;
            $f = $m->[$j]->[$i];
            for($k = 0; $k <= $mc; $k++) {
                $m->[$j]->[$k] -= $m->[$i]->[$k] * $f;
            }
        }
    }
# Answer is in augmented column    
    transpose new Math::Matrix @{$m->transpose}[$mr+1 .. $mc];
}

sub print {
    my $self = shift;
    
    print @_ if $#_ >= $_;
    for $row (@{$self}) {
        for $col (@{$row}) {
            printf "%10.5f ", $col;
        }
        print "\n";
    }
}

1;
