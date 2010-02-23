Event.observe(window, 'load', function() {
  $$('.popup .input').each(function(input) {
    Event.observe(input, 'click', function() {
      input.addClassName('active');
      input.down('input').focus();
    });
  });

  $$('.popup .input input').each(function(input) {
    Event.observe(input, 'blur', function() {
      var p = input.up('.input');
      p.removeClassName('active');

      var error = p.down('.error');
      if(error) {
        error.remove();
      }

      if(input.value && input.type != 'password') {
        p.down('.label').innerHTML = input.value;
      }
    });
  });
});

function submitPopup(link) {
  var popup = $(link).up('.popup');
  var form = popup.down('form');
  popup.select('.error').each(function(error) {
    error.remove();
  });

  form.request({
    method: 'post',
    onSuccess: function(transport) {
      alert(transport.responseJSON);
      $A(transport.responseJSON).each(function(error) {
        form.getInputs().each(function(input) {
          var p = input.up('.input');
          if (p && !p.down('.error')) {
            var match = input.name.match(/\[([^[]*)\]$/) 
            if(match && error[0] == match[1]) {
              var element = document.createElement('div');
              element.className = 'error';
              element.innerHTML = error[1];
              p.insert({top: element});
            }
          }
        });
      });
    }
  });
  return false;
}
