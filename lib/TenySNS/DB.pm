package TenySNS::DB;
use strict;
use warnings;
use utf8;
use parent qw(Teng);
use String::Random;
use Digest::SHA1 qw(sha1_hex);
use Time::Piece;

__PACKAGE__->load_plugin('Count');
__PACKAGE__->load_plugin('Replace');
__PACKAGE__->load_plugin('Pager');

sub _generate_salt {
  my $len = 12;
  String::Random->new->randregex("[A-Za-z0-9]{$len}");
}

sub _hash_password {
    my ($password, $salt) = @_;
    sha1_hex($salt . 'aGb38Rq9' . $password);
}

sub create_user {
    my ($self, $name, $email, $password) = @_;
    my $salt = _generate_salt;
    my $hashed_password = _hash_password($password, $salt);
    $self->insert(user => {
        name       => $name,
        email      => $email,
        password   => $hashed_password,
        salt       => $salt,
        bio        => '',
        created_at => Time::Piece->new,
    });
}

sub auth_user {
    my ($self, $email, $password) = @_;
    my $user = $self->single(user => { email => $email });

    return unless $user;
    return unless $user->password eq _hash_password($password, $user->salt);

    $user;
}

1;
