package TenySNS::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;

any '/' => sub {
    my ($c) = @_;
    $c->render('index.tx');
};

get '/login' => sub {
    my ($c) = @_;
    $c->render('login.tx');
};

post '/logout' => sub {
    my ($c) = @_;
    $c->session->expire();
    $c->redirect('/');
};

1;
