package TenySNS::Web::Dispatcher;
use 5.012;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use Data::Dumper;

any '/' => sub {
    my ($c) = @_;
    my $user = $c->db->single(user => { id => $c->session->get('user_id') });
    $c->render('index.tx', {
        user => $user,
        csrf_token => $c->get_csrf_defender_token,
    });
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

get '/api/tweets' => sub {
    my ($c) = @_;
    my @tweets = map {
        +{
            id         => $_->id,
            text       => $_->text,
            created_at => $_->created_at->epoch,
        }
    } $c->db->search(tweet => {}, { order_by => 'created_at DESC' });

    $c->render_json({
        status => 200,
        tweets => \@tweets,
    });
};

post '/api/tweets' => sub {
    my ($c) = @_;
    my $user_id = $c->session->get('user_id');
    my $text = $c->req->param('text');

    return $c->render_json({ status => 401, error => 'Cannot authorize' }) unless $user_id;
    return $c->render_json({ status => 403, error => 'Empty text' }) unless $text;

    my $tweet = $c->db->insert(tweet => {
        user_id    => $user_id,
        text       => $text,
        created_at => Time::Piece->new,
    });

    $c->render_json({
        status => 200,
        tweet  => {
            id   => $tweet->id,
            text => $tweet->text,
        },
    });
};

get '/api/users' => sub {
    my ($c) = @_;
    my @users = map {
        +{
            id        => $_->id,
            name      => $_->name,
            email     => $_->email,
            bio       => $_->bio,
            create_at => $_->created_at->epoch,
        }
    } $c->db->search(user => {}, {});

    $c->render_json({
        status => 200,
        users  => \@users,
    });
};

1;
