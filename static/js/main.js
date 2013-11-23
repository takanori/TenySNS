if (typeof(window.console) == "undefined") { console = {}; console.log = console.warn = console.error = function(a) {}; }

$(function () {
    $('#logout-link').click(function () {
        $('#logout-form').submit();
    });
});
