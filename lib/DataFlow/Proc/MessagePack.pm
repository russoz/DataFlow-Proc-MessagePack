package DataFlow::Proc::MessagePack;

use strict;
use warnings;

# ABSTRACT: A MessagePack converting processor

# VERSION

use Moose;
extends 'DataFlow::Proc::Converter';

use namespace::autoclean;
use Data::MessagePack;

sub _policy {
    return shift->direction eq 'CONVERT_TO' ? 'ArrayRef' : 'Scalar';
}

has '+converter' => (
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->has_converter_opts
          ? Data::MessagePack->new( $self->converter_opts )
          : Data::MessagePack->new;
    },
    'handles' => {
        'msgpack'          => sub { shift->converter(@_) },
        'msgpack_opts'     => sub { shift->converter_opts(@_) },
        'has_msgpack_opts' => sub { shift->has_converter_opts },
    },
    'init_arg' => 'msgpack',
);

has '+converter_opts' => ( 'init_arg' => 'msgpack_opts', );

sub _build_subs {
    my $self = shift;

    my $subs = {
        'TO_MSGPACK' => sub {
            return $self->msgpack->pack($_);
        },
        'FROM_MSGPACK' => sub {
            return $self->msgpack->unpack($_);
        },
    };

    return $subs;
}

__PACKAGE__->meta->make_immutable;

1;

