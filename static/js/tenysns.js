$(function() {
    var csrf_token = $('#csrf_token').val();

    $.get(
        '/api/tweets',
        {},
        function (data) {
            var tweets = data.tweets;
            var $tweets = $('#tweets');
            var i, len;
            for (i=0, len=tweets.length; i<len; i++) {
                var $p = $('<p>').text(tweets[i].text);
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
                var $p = $('<p>').text(tweet.text);
                console.log($p);
                $('<div>').append($p).prependTo($('#tweets'));
            },
            'json'
        );
        return false;
    });
});
