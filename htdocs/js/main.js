(function(){
    var options = {},
        siteUrl;

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

    function loadDependencies(dependencies, onReadyFn) {
        var libs = [];

        for (dependency in dependencies) {
            if (dependencies.hasOwnProperty(dependency)) {
                libs.push(options.siteUrl + 'js/' + dependencies[dependency]);
            }
        }

        $LAB.script(libs)
            .wait(onReadyFn)
    }

    function saveRate(score, event) {
        $.ajax({
            url:         options.apiUrl + "rating/" + resourceId,
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
            path: siteUrl + 'img/raty/',
            start: parseInt(rate, 10),
            click: readOnly ?
                function(score, event) {
                    event.preventDefault();
                    event.stopPropagation();
                } :
                saveRate,
            readOnly: readOnly
        }).fadeIn();
    }

    function initRaty(resourceId) {
        var $rating = $("#rating");

        if ($rating.size() === 0 || '' === resourceId) {
            return;
        }

        $.ajax({
            url:         options.apiUrl + "rating/" + resourceId,
            type:        'GET',
            dataType:    'json',
            error:       function(jqXhr, textStatus, errorThrown) {
                if (404 === jqXhr.status) {
                    showRaty(0);
                }
            }   ,
            success:     function(data) {
                if (data && data.average !== undefined) {
                    showRaty(data.average);
                }
            }
        });
    }

    function initComments(resourceId) {
        var $rating = $("#comments");

        if ($rating.size() === 0 || '' === resourceId) {
            return;
        }
    }

    function main() {
        var dependencies = [
            'jquery-1.7.2.js',
            'jquery.raty.js',
            'handlebars.js'
        ];

        loadDependencies(dependencies, function() {
            $.ajaxSetup({
                cache:       false,
                processData: false,
                dataType:    "json",
                contentType: "application/json"
            });
            $(function() {
                var pathname   = document.location.pathname,
                    resourceId = pathname.replace(".html", "")
                                         .substring(pathname.lastIndexOf("/") + 1);
                initRaty(resourceId);
                initComments(resourceId);
            });
        });
        initGoogleAnalytics();
    }

    function uberblog(opt) {
        options = opt || {};
        siteUrl = opt.siteUrl;
        main();
    }

    window.weltraumschaf = window.uberblog = uberblog; // backward compatibility
})()