(function(){
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
})()