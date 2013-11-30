$(function () {
    $('#logout-link').click(function () {
        $('#logout-form').submit();
    });
});

angular.module('sns', ['ngRoute'])
.config(function ($routeProvider) {
    $routeProvider
    .when('/', {
        controller: 'MainControl',
        templateUrl: 'static/html/index.html',
    }).otherwise({
        redirectTo: '/',
    });
})
.controller('MainControl', function ($scope, $http) {

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
        $http({
            url: '/api/tweets',
            method: 'POST',
            params: { text: $scope.draft, csrf_token: App.csrf_token },
        }).success(function (data) {
            $scope.tweets.unshift(data.tweet);
            console.log(data);
        });

        $scope.draft = '';
        $('#tweet-text').focus();

        return false;
    };
});
