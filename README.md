[![Build Status](https://travis-ci.com/skaji/Mojo-TailFile.svg?branch=master)](https://travis-ci.com/skaji/Mojo-TailFile)
[![AppVeyor Status](https://ci.appveyor.com/api/projects/status/github/skaji/Mojo-TailFile?branch=master&svg=true)](https://ci.appveyor.com/project/skaji/Mojo-TailFile)

# NAME

Mojo::TailFile - non-blocking tail file with Mojo::IOLoop

# SYNOPSIS

    use Mojo::TailFile;

    my $tail = Mojo::TailFile->new(path => "/path/to/file");
    $tail->on(line => sub {
      my ($tail, $line) = @_;
      chomp $line;
      warn "GOT: $line";
    });
    $tail->start;

# DESCRIPTION

Mojo::TailFile tails files.

This class inherits all events, methods, attributes from [Mojo::EventEmitter](https://metacpan.org/pod/Mojo::EventEmitter).

# EVENTS

## line

    $tail->on(line => sub {
      my ($tail, $line) = @_;
      chomp $line;
      warn "GOT: $line";
    });

# METHODS

## start

    $tail->start;

## stop

    $tail->stop;

# ATTRIBUTES

## open\_layer

## path

## tick

## timeout

# AUTHOR

Shoichi Kaji <skaji@cpan.org>

# COPYRIGHT AND LICENSE

Copyright 2018 Shoichi Kaji <skaji@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
