package TenySNS::Web::Dispatcher;
use 5.012;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use Data::Dumper;

any '/' => sub {
    my ($c) = @_;
    say(Dumper($c->session->get('user_id')));
    $c->render('index.tx');
};

post '/signup' => sub {
    my ($c) = @_;
    my $name = $c->req->param('name');
    my $email = $c->req->param('email');
    my $password = $c->req->param('password');
    my $user = $c->db->create_user($name, $email, $password);

    $c->session->set(user_id => $user->id);

    $c->redirect('/');
};

post '/login' => sub {
    my ($c) = @_;
    my $email = $c->req->param('email');
    my $password = $c->req->param('password');
    my $user = $c->db->auth_user($email, $password);

    $c->session->set(user_id => $user->id);

    $c->redirect('/');
};

post '/logout' => sub {
    my ($c) = @_;
    $c->session->expire();
    $c->redirect('/');
};

1;
