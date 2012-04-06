(function() {
    var options = {};

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

    function saveRate(score, event, resourceId) {
        var $container = $(this);

        $.ajax({
            url:      options.apiUrl + "rating/" + resourceId,
            type:     'PUT',
            data:     JSON.stringify({"rate": score}),
            dataType: 'json',
            error:    function(jqXhr, textStatus, errorThrown) {
                console.log("Error on Ajax request!")
                console.debug(jqXhr, textStatus, errorThrown);
            },
            success:     function(data) {
                // @todo errorhandling

                if (data && data.average) {
                    $container.raty('start', data.average)
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

    function showRaty($container, resourceId, rate, readOnly) {
        rate     = rate || 0;
        readOnly = readOnly || false;
        $container.raty({
            path: options.siteUrl + 'img/raty/',
            start: parseInt(rate, 10),
            click: readOnly
                ?
                function(score, event) {
                    // Set dummy callback.
                    event.preventDefault();
                    event.stopPropagation();
                }
                :
                function(score, event) {
                    saveRate.call(this, score, event, resourceId);
                },
            readOnly: readOnly
        }).fadeIn();
    }

    function initRaty(resourceId) {
        var $container = $("#rating");

        if ($container.size() === 0 || '' === resourceId) {
            return;
        }

        $.ajax({
            url:      options.apiUrl + "rating/" + resourceId,
            type:     'GET',
            dataType: 'json',
            error:    function(jqXhr, textStatus, errorThrown) {
                if (404 === jqXhr.status) {
                    showRaty($container, resourceId);
                }
            }   ,
            success:  function(data) {
                if (data && data.average !== undefined) {
                    showRaty($container, resourceId, data.average);
                }
            }
        });
    }

    function showCommentsForm($container) {
        var template = Handlebars.compile($('#comments-form-tpl').html());
        $container.append(template()).fadeIn();
    }

    function showComments($container, comments) {
        comments = comments || [];
    }

    function saveComment(event) {
        event.stopPropagation();
        event.preventDefault();
    }

    function initComments(resourceId) {
        var $container = $("#comments");

        if ($container.size() === 0 || '' === resourceId) {
            return;
        }

        $container.append('<div class="comments-list"/><div class="comments-form"/>')
                  .children()
                  .hide()
                  .end()
                  .show();
//        $.ajax({
//            url:      options.apiUrl + "comments/" + resourceId,
//            type:     'GET',
//            dataType: 'json',
//            error:    function(jqXhr, textStatus, errorThrown) {
//                if (404 === jqXhr.status) {
//                    showComments($container);
//                }
//            }   ,
//            success:  function(data) {
//                if (data !== undefined) {
//                    showComments($container, data);
//                }
//            }
//        });
        showCommentsForm($container.find('.comments-form'));
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