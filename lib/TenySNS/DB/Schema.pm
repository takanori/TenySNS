package TenySNS::DB::Schema;
use strict;
use warnings;
use utf8;

use Teng::Schema::Declare;
use Time::Piece;

base_row_class 'TenySNS::DB::Row';

my $time_inflate = sub {
    Time::Piece->new(shift);
};

my $time_deflate = sub {
    shift->epoch;
};

table {
    name 'user';
    pk 'id';
    columns qw/id name email password salt bio created_at/;
    inflate qr/.+_at/ => $time_inflate;
    deflate qr/.+_at/ => $time_deflate;
};

table {
    name 'tweet';
    pk 'id';
    columns qw/id user_id text created_at/;
    inflate qr/.+_at/ => $time_inflate;
    deflate qr/.+_at/ => $time_deflate;
};

1;
