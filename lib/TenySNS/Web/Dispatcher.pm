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

    return $c->render_json({ status => 403, error => 'Not authorized' }) unless $user_id;
    return $c->render_json({ status => 403, error => 'Invalid query' }) unless $text;

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

get '/api/users/me' => sub {
    my ($c, $args) = @_;
    my $id = $c->session->get('user_id');

    return $c->render_json({ status => 403, error => 'Not authorized' }) unless $id;

    my $user = $c->db->single(user => { id => $id });

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

get '/api/users/me/followers' => sub {
    my ($c) = @_;
    my $id = $c->session->get('user_id');

    return $c->render_json({ status => 403, error => 'Not authorized' }) unless $id;

    my @followers = $c->db->search_by_sql(q{
        SELECT
            user.*
        FROM user, follow
        WHERE follow.followee_id = ? AND user.id = follow.follower_id
    }, [ $id ]);

    $c->render_json({
        status => 200,
        followers => \@followers,
    });
};

get '/api/users/:id' => sub {
    my ($c, $args) = @_;
    my $id = $args->{id};
    my $user = $c->db->single(user => { id => $id });

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

post '/api/users/:id/follow' => sub {
    my ($c, $args) = @_;
    my $follower_id = $c->session->get('user_id');
    my $followee_id = $args->{id};

    return $c->render_json({ status => 403, error => 'Not authorized' }) unless $follower_id;

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

post 'api/favorite' => sub {
    my ($c)      = @_;
    my $user_id  = $c->session->get('user_id');
    my $tweet_id = $c->req->param('tweet_id');

    return $c->render_json( { status => 403, error => 'Not authorized' } ) unless $user_id;
    return $c->render_json( { status => 403, error => 'Invalid query' } )  unless $tweet_id;

    my $favorite = $c->db->insert(
        favorite => {
            user_id    => $user_id,
            tweet_id   => $tweet_id,
            created_at => Time::Piece->new,
        }
    );

    $c->render_json(
        {   status   => 200,
            favorite => {
                id       => $favorite->id,
                tweet_id => $favorite->tweet_id,
            },
        }
    );
};

get '/api/users/me/favorites' => sub {
    my ( $c, $args ) = @_;
    my $id = $c->session->get('user_id');

    return $c->render_json( { status => 403, error => 'Not authorized' } ) unless $id;

    my @favorites = $c->db->search_by_sql(
        q{
        SELECT tweet.*
          FROM tweet
          JOIN favorite
            ON favorite.tweet_id = tweet.id
         WHERE favorite.user_id  = ?
        }, [$id]
    );

    $c->render_json(
        {   status    => 200,
            favorites => \@favorites,
        }
    );
};

1;
