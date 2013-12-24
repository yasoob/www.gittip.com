Gittip.tips = {};

Gittip.tips.init = function() {

    // Check the tip value on change, or a second after the user stops typing.
    var $tip = $('input.my-tip:not(.anon)'), timer;
    $tip.change(checkTip);
    $tip.keyup(function(e) {
        if (e.keyCode === 13) // enter
            $('.my-tip .confirm-tip').focus().click();
        else if (e.keyCode === 27) // escape
            $('.my-tip .cancel-tip').focus().click();
        else if (e.keyCode === 38 || e.keyCode === 40) // up & down
            return; // causes inc/decrement in HTML5, triggering the change event
        else {
            clearTimeout(timer);
            timer = setTimeout(checkTip.bind(this), 1000);
        }
    });

    function checkTip() {
        var $this     = $(this),
            $parent   = $this.parents('.my-tip'),
            $confirm  = $parent.find('.confirm-tip'),
            amount    = parseFloat($this.val(), 10) || 0,
            oldAmount = parseFloat($this.data('old-amount'), 10);

        // force two decimal points on value
        $this.val(amount.toFixed(2));

        // dis/enables confirm button as needed
        $confirm.prop('disabled', amount == oldAmount);

        if (amount === oldAmount)
            $parent.removeClass('changed');
        else
            $parent.addClass('changed');

        // show/hide the payment prompt
        if (amount === 0)
            $('#payment-prompt').removeClass('needed');
        else
            $('#payment-prompt').addClass('needed');
    }

    $('.my-tip .cancel-tip').click(function(event) {
        event.preventDefault();

        var $myTip = $(this).parents('.my-tip').find('.my-tip');

        $myTip.val($myTip.data('old-amount')).change();
    });

    $('.my-tip .tip-suggestions a').click(function(event) {
        event.preventDefault();

        var $this  = $(this),
            $myTip = $this.parents('.my-tip').find('.my-tip');

        $myTip.val($this.text().match(/\d+/)[0] / ($this.hasClass('cents') ? 100 : 1)).change();
    });

    $('.my-tip .confirm-tip').click(function() {
        var $this     = $(this),
            $myTip    = $this.parents('.my-tip').find('.my-tip'),
            amount    = parseFloat($myTip.val(), 10),
            oldAmount = parseFloat($myTip.data('old-amount'), 10),
            tippee    = $myTip.data('tippee');

        if (amount == oldAmount)
            return;

        $.post('/' + tippee + '/tip.json', { amount: amount }, function(data) {
            // lock-in changes
            $myTip.data('old-amount', amount).change();

            // update display
            $('.total-giving').text(data.total_giving);
            $('.total-receiving').text(
                // check and see if we are on our giving page or not
                new RegExp('/' + tippee + '/').test(window.location.href) ?
                    data.total_receiving_tippee : data.total_receiving);

            // update quick stats
            $('.quick-stats a').text('$' + data.total_giving + '/wk');

            alert("Tip changed to $" + amount + "!");
        })
        .fail(function() {
            alert('Sorry, something went wrong while changing your tip. :(');
            console.log.apply(console, arguments);
        })
    });


    // For anonymous users we flash a login link.

    $('.my-tip-range.anon button').mouseover(function() {
        $('.sign-in-to-give .dropdown-toggle').addClass('highlight');
    });
    $('.my-tip-range.anon button').click(function() {
        var i = 0;
        (function flash() {
            if (i++ == 6) return;
            $('.sign-in-to-give .dropdown-toggle').toggleClass('highlight');
            setTimeout(flash, 100);
        })();
    });
};

