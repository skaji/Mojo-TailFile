package Mojo::TailFile;

use Mojo::Base 'Mojo::EventEmitter';
use Mojo::IOLoop;

our $VERSION = '0.001';

has 'open_layer' => '';
has 'path';
has 'tick' => 0.1;
has 'timeout' => 15;

has '_fh';
has '_inactive' => 0;
has '_loop';

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->path or die "path is required for $class" if !$self->path;
    open my $fh, "<" . $self->open_layer, $self->path or die "@{[ $self->path ]}: $!";
    $self->_fh($fh);
    $self;
}

sub DESTROY {
    my $self = shift;
    $self->stop;
}

sub stop {
    my $self = shift;
    return if !$self->_loop;
    Mojo::IOLoop->remove($self->_loop);
    $self->_loop(undef);
}

sub start {
    my $self = shift;
    $self->_read;
    my $loop = Mojo::IOLoop->recurring($self->tick => sub {
        seek $self->_fh, 0, 1;
        my $emitted = $self->_read;
        return if !$self->timeout;
        if ($emitted) {
            $self->_inactive(0);
        } else {
            my $inactive = $self->_inactive;
            $inactive += $self->tick;
            if ($inactive > $self->timeout) {
                $self->stop;
                return;
            }
            $self->_inactive($inactive);
        }
    });
    $self->_loop($loop);
    Mojo::IOLoop->start if !Mojo::IOLoop->is_running;
    1;
}

sub _read {
    my $self = shift;
    my $fh = $self->_fh;
    my $emitted = 0;
    while (my $line = <$fh>) {
        $emitted++;
        $self->emit(line => $line);
    }
    $emitted;
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojo::TailFile - non-blocking tail file with Mojo::IOLoop

=head1 SYNOPSIS

  use Mojo::TailFile;

  my $tail = Mojo::TailFile->new(path => "/path/to/file");
  $tail->on(line => sub {
    my ($tail, $line) = @_;
    chomp $line;
    warn "GOT: $line";
  });
  $tail->start;

=head1 DESCRIPTION

Mojo::TailFile tails files.

This class inherits all events, methods, attributes from L<Mojo::EventEmitter>.

=head1 EVENTS

=head2 line

  $tail->on(line => sub {
    my ($tail, $line) = @_;
    chomp $line;
    warn "GOT: $line";
  });

=head1 METHODS

=head2 start

  $tail->start;

=head2 stop

  $tail->stop;

=head1 ATTRIBUTES

=head2 open_layer

=head2 path

=head2 tick

=head2 timeout

=head1 AUTHOR

Shoichi Kaji <skaji@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Shoichi Kaji <skaji@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
