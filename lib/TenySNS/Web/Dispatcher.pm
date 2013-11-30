package TenySNS::Web::Dispatcher;
use 5.012;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use Data::Dumper;

any '/' => sub {
    my ($c) = @_;
    my $user = $c->current_user;
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
    my @tweets = $c->db->search_tweets;

    $c->render_json({
        status => 200,
        tweets => \@tweets,
    });
};

post '/api/tweets' => sub {
    my ($c) = @_;
    my $user = $c->current_user;
    my $text = $c->req->param('text');

    return $c->render_json({ status => 403, error => 'Not authorized' }) unless $user;
    return $c->render_json({ status => 403, error => 'Invalid query' }) unless $text;

    my $tweet = $c->db->insert(tweet => {
        user_id    => $user->id,
        text       => $text,
        created_at => Time::Piece->new,
    });

    $c->render_json({
        status => 200,
        tweet  => {
            id         => $tweet->id,
            text       => $tweet->text,
            created_at => $tweet->created_at->epoch,
            user       => {
                id         => $user->id,
                name       => $user->name,
            }
        },
    });
};

get '/api/users' => sub {
    my ($c) = @_;
    my @users = $c->db->search_users;

    $c->render_json({
        status => 200,
        users  => \@users,
    });
};

get '/api/users/:id' => sub {
    my ($c, $args) = @_;
    my $id = $args->{id};
    my $user = $id eq 'me' ? $c->current_user : $c->db->single(user => { id => $id });

    return $c->render_json({ status => 403, error => 'Invalid query' }) unless $user;

    $c->render_json({
        status => 200,
        user   => {
            id         => $user->id,
            name       => $user->name,
            email      => $user->email,
            bio        => $user->bio,
            created_at => $user->created_at->epoch,
        }
    });
};

get '/api/users/:id/followers' => sub {
    my ($c, $args) = @_;
    my $id = $args->{id};
    my $user = $id eq 'me' ? $c->current_user : $c->db->single(user => { id => $id });

    return $c->render_json({ status => 403, error => 'Not authorized' }) unless $user;

    my @followers = $c->db->search_by_sql(q{
        SELECT
            user.*
        FROM user, follow
        WHERE follow.followee_id = ? AND user.id = follow.follower_id
    }, [ $user->id ]);

    $c->render_json({
        status => 200,
        followers => \@followers,
    });
};

post '/api/users/:id/follow' => sub {
    my ($c, $args) = @_;
    my $user = $c->current_user;
    return $c->render_json({ status => 403, error => 'Not authorized' }) unless $user;

    my $follower_id = $user->id;
    my $followee_id = $args->{id};

    my $followee = $c->db->single(user => { id => $followee_id });

    return $c->render_json({ status => 404, error => 'Such user doesn\'t exist' }) unless $followee;

    $c->db->insert(follow => {
        follower_id => $follower_id,
        followee_id => $followee_id,
        created_at  => Time::Piece->new,
    });

    $c->render_json({
        status => 200,
    });
};

1;
