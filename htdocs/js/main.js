(function(){
    var apiUrl;

    function initGoogleAnalytics() {
        var _gaq = _gaq || [], ga, s;

        try {
            _gaq.push(['_setAccount', 'UA-9617079-2']);
            _gaq.push(['_gat._anonymizeIp']);
            _gaq.push(['_trackPageview']);
            ga = document.createElement('script');
            ga.type  = 'text/javascript';
            ga.async = true;

            if ('https:' == document.location.protocol) {
                ga.src = 'https://ssl.google-analytics.com/ga.js';
            }
            else {
                ga.src = 'http://www.google-analytics.com/ga.js';
            }

            s = document.getElementsByTagName('script')[0];
            s.parentNode.insertBefore(ga, s);
        } catch(err) {
            if (window.console && window.console.log) {
                console.log('exception throwed while GA-Tracking of type: ' +
                            err.type + ' and message: ' + err.message);
            }
        }
    }

    function loadDependencies(onReadyFn) {
        $LAB.script('js/jquery-1.7.2.js')
            .script('js/jquery.raty.js')
            .wait(onReadyFn)
    }

    function initRaty() {
        var $rating    = $("#rating"),
            pathname   = document.location.pathname,
            resourceId = pathname.replace(".html", "")
                                 .substring(pathname.lastIndexOf("/") + 1);

        if ($rating.size() === 0 || '' === resourceId) {
            return;
        }

        $.ajax({
            url: apiUrl + "rating/" + resourceId,
            dataType: 'json',
            crossDomain: true,
            success: function(data) {
                console.debug(data);
                $("#rating").raty({
                    path: "img/raty/",
                    start: data.average,
                    click: function(score, event) {
                        console.debug(score);
                    }
                }).fadeIn();
            }
        });
    }

    function main() {
        loadDependencies(function() {
            $(initRaty);
        });
        initGoogleAnalytics();
    }

    window.weltraumschaf = function(options) {
        apiUrl = options.api;
        main();
    }
})()