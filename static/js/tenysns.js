$(function() {
    var csrf_token = $('#csrf_token').val();
    var $tweets = $('#tweets');
    var $favorites = $('#favorites');

    // TODO function to add a tweet

    $.get(
        '/api/tweets',
        {},
        function (data) {
            var tweets = data.tweets;
            var i, len;
            for (i=0, len=tweets.length; i<len; i++) {
                var $p = $('<p>').attr('id', tweets[i].id).text(tweets[i].text);
                $p.addClass('tweet_text').css({'cursor': 'pointer', 'background-color': '#DDD'});
                $('<div>').append($p).appendTo($tweets);
            }
        }
    );

    $.get(
        '/api/users',
        {},
        function (data) {
            var users = data.users;
            var $users = $('#users');
            var i, len;
            for (i=0, len=users.length; i<len; i++) {
                var $p = $('<p>').text(users[i].name);
                $('<div>').append($p).appendTo($users);
            }
        }
    );

    $.get(
        '/api/users/me/favorites',
        {},
        function (data) {
            var favorites = data.favorites;
            var len = favorites.length;
            for (var i = 0; i < len; i++) {
                var $p = $('<p>').text(favorites[i].id + ': ' + favorites[i].text);
                $('<div>').append($p).appendTo($favorites);
            }
        }
    );

    $('#tweet-button').click(function () {
        var $text = $('#tweet-text');
        var text = $text.val();

        $text.val('');
        $text.focus();

        $.post(
            '/api/tweets',
            { text: text, csrf_token: csrf_token },
            function (data) {
                var tweet = data.tweet;
                var $p = $('<p>').attr('id', tweet.id).text(tweet.text);
                $p.addClass('tweet_text').css({'cursor': 'pointer', 'background-color': '#DDD'});
                $('<div>').append($p).prependTo($tweets);
            },
            'json'
        );
        return false;
    });

    // favorite 
    $tweets.on('click', '.tweet_text', function() {
        var tweet_id = $(this).attr('id');
        var tweet_text = $(this).text();
        if (window.confirm('id: ' + tweet_id + '\n' + tweet_text + '\nをお気に入りに入れますか？')) {
            $.post(
                'api/favorite',
                { tweet_id: tweet_id, csrf_token: csrf_token },
                function (data) {
                    var favorite = data.favorite;
                    var $p = $('<p>').text(favorite.tweet_id + ': ' + tweet_text);
                    $('<div>').append($p).prependTo($favorites);
                },
                'json'
            );
        }
        return false;
    });
});
