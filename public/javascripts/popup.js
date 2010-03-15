Event.observe(window, 'load', function() {
  $$('.popup .input').each(function(input) {
    if(input.down('.label')) {
      Event.observe(input, 'click', function() {
        if(!input.hasClassName('active') && input.down('input')) {
          input.addClassName('active');
          input.down('input').focus();
        }
      });
    }
  });

  $$('.popup .input input').each(function(input) {
    var p = input.up('div.input');

    var onchange = function() {
      var error = p.down('.error');
      if(error) {
        error.remove();
      }
    };
    Event.observe(input, 'blur', onchange);
    Event.observe(input, 'custom:change', onchange);

    Event.observe(input, 'blur', function() {
      p.removeClassName('active');

      var label = p.down('.label');
      if(input.value && input.type != 'password' && label) {
        label.innerHTML = input.value;
      }
    });
  });
});
