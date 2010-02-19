Event.observe(window, 'load', function() {
  $$('.popup .input').each(function(input) {
    Event.observe(input, 'click', function() {
      $$('.popup .input.active').each(function(active) {
        active.removeClassName('active');
      });
      input.addClassName('active');
      input.down('input').focus();
    });
  });

  $$('.popup .input input').each(function(input) {
    Event.observe(input, 'blur', function() {
      input.up().removeClassName('active');
    });
  });
});
