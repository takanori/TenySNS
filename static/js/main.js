$(function () {
    $('#logout-link').click(function () {
        $('#logout-form').submit();
    });
});

var MainControl = function ($scope, $http) {

    $scope.tweets = [];
    $scope.users = [];

    $http({
        url: '/api/tweets',
        method: 'GET',
        data: {},
    }).success(function (data) {
        $scope.tweets = data.tweets;
        console.log(data);
    });

    $http({
        url: '/api/users',
        method: 'GET',
        data: {},
    }).success(function (data) {
        $scope.users = data.users;
        console.log(data);
    });

    $scope.tweet = function () {
        var $text = $('#tweet-text')
        var text = $text.val();

        $text.val('');
        $text.focus();

        $.post(
            '/api/tweets',
            { text: text, csrf_token: App.csrf_token },
            function (data) {
                var tweet = data.tweet;
                var $p = $('<p>').text(tweet.text);
                console.log($p);
                $('<div>').append($p).prependTo($('#tweets'));
            },
            'json'
        );
        return false;
    };
};
