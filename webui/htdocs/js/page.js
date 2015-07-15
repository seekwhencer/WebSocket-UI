jQuery(window).ready(function($) {

    jQuery('body').on('click', function() {
        //Page.resizeMainNav();
        //Page.resizeMainContent();
    });

    $('body').trigger('click');
    $('body').trigger('click');

    $('.tooltip-mainnavi-pointer').tooltip({
        placement : 'bottom'
    });
    

    $('#button-toggle-fullscreen').on('click', function() {
        $(document).toggleFullScreen();
    }); 


});

jQuery(window).on('resize', function($) {
    //Page.resizeMainNav();
    //Page.resizeMainContent();
});

jQuery(window).on('scroll', function($) {
    //Page.resizeMainNav();
    //Page.resizeMainContent();
});

/*
 * Page Object
 */
var Page = {

    resizeMainNav : function() {
        $('.main-nav').height(0);
        $('.main-nav').height($(document).innerHeight());
    },

    resizeMainContent : function() {
        var inner = $(window).innerHeight();
        var head = $('.main-head').outerHeight();
        $('.main-content').height(inner - head - 10);
    }
};

function formatSecondsAsTime(secs, format) {
    var hr = Math.floor(secs / 3600);
    var min = Math.floor((secs - (hr * 3600)) / 60);
    var sec = Math.floor(secs - (hr * 3600) - (min * 60));

    if (min < 10) {
        min = "0" + min;
    }
    if (sec < 10) {
        sec = "0" + sec;
    }

    return min + ':' + sec;
}
