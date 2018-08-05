use strict;
use warnings;
use Test::More;
use Mojo::TailFile;
use File::Temp 'tempfile';

sub append {
    my ($path, $str) = @_;
    open my $fh, ">>", $path or die;
    print {$fh} $str;
    close $fh;
}

(undef, my $path) = File::Temp::tempfile(UNLINK => 1, OPEN => 0, EXLOCK => 0);
append $path, "1\n2\n3\n";

my @got;
my $tail = Mojo::TailFile->new(path => $path, tick => 0.05);
$tail->on(line => sub { (undef, my $line) = @_; push @got, $line });
Mojo::IOLoop->timer(1   => sub { $tail->stop });
Mojo::IOLoop->timer(0.2 => sub { is @got, 3; append $path, "4\n" });
Mojo::IOLoop->timer(0.4 => sub { is @got, 4; append $path, "5\n6\n" });
Mojo::IOLoop->timer(0.6 => sub { is @got, 6; append $path, "7\n" });
$tail->start;

is_deeply \@got, [ "1\n", "2\n", "3\n", "4\n", "5\n", "6\n", "7\n" ];

done_testing;
