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

function submitPopup(link) {
  var popup = $(link).up('.popup');
  var form = popup.down('form');
  popup.select('.error').each(function(error) {
    error.remove();
  });
  showMessage('info', 'Processing request...');

  form.request({
    method: 'post',
    onSuccess: function(transport) {
      handlePopupResponse(form, transport);
    }
  });
  return false;
}

function handlePopupResponse(form, transport) {
  clearMessage();

  $A(transport.responseJSON).each(function(error) {
    if(error[0] == 'base') {
      showMessage('error', error[1]);    
    } else {
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
    }
  });
}
