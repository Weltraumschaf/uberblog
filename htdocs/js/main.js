(function(){
    var apiUrl,
        pathname   = document.location.pathname,
        resourceId = pathname.replace(".html", "")
                             .substring(pathname.lastIndexOf("/") + 1);

    if (undefined === window.console) {
        window.console = {
            debug: function() {},
            log: function() {}
        };
    }
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

    function saveRate(score, event) {
        $.ajax({
            url:         apiUrl + "rating/" + resourceId,
            type:        'PUT',
            data:        JSON.stringify({"rate": score}),
            dataType:    'json',
            error:       function(jqXhr, textStatus, errorThrown) {
                console.debug(jqXhr, textStatus, errorThrown);
            },
            success:     function(data) {
                // @todo errorhandling

                if (data && data.average) {
                    $("#rating").raty('start',data.average)
                                .raty('readOnly', true);
                } else {
                    console.log("Didn't get expected data!");
                    console.debug(data);
                }
            }
        });
        event.preventDefault();
        event.stopPropagation();
    }

    function showRaty(rate, readOnly) {
        readOnly = readOnly || false;
        $("#rating").raty({
            path: "img/raty/",
            start: rate,
            click: readOnly ?
                function(score, event) {
                    event.preventDefault();
                    event.stopPropagation();
                } :
                saveRate,
            readOnly: readOnly
        }).fadeIn();
    }

    function initRaty() {
        var $rating = $("#rating");

        if ($rating.size() === 0 || '' === resourceId) {
            return;
        }

        $.ajax({
            url:         apiUrl + "rating/" + resourceId,
            type:        'GET',
            dataType:    'json',
            error:       function(jqXhr, textStatus, errorThrown) {
                if (404 === jqXhr.status) {
                    showRaty(0);
                }
            }   ,
            success:     function(data) {
                if (data && data.average) {
                    showRaty(data.average);
                }
            }
        });
    }

    function main() {
        loadDependencies(function() {
            $.ajaxSetup({
                cache:       false,
                processData: false,
                dataType:    "json",
                contentType: "application/json"
            });
            $(initRaty);
        });
        initGoogleAnalytics();
    }

    window.weltraumschaf = function(options) {
        apiUrl = options.api;
        main();
    }
})()