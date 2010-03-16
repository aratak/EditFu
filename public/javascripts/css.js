function hidePopup() {
  $('popup-hider').up().fade({ duration: 0.2})
}

function setInputValue(input, value) {
  toggleInputClass(input, value);
  input.value = value;
}

function toggleInputClass(input, value) {
  if(!value) {
    value = input.getValue();
  }
  if(value.blank()) {
    input.removeClassName('with-text');
  } else {
    input.addClassName('with-text');
  }
}

var Behaviours = function() {
  return {

    labels: function() {
      $$('.label-input input').each(function(input) {
        Event.observe(input, 'blur', function() {
          toggleInputClass(input);
        });
      });
      
      $$('.label-input input').each(function(input) {
          toggleInputClass(input);
      });
    },
    
    radioButtons: function() {
      $$('.plan input.radio').each(function(input) {
        if(input.checked) {
          input.next().addClassName('checked');
        }
        Event.observe(input, 'change', function() {
          $$('.plan .plan-label').invoke('removeClassName', 'checked');
          input.next().addClassName('checked');
        });
      });
    },

    popup: function() {
      Event.observe('popup-hider', 'click', function(e) {
        hidePopup()
      })
    },
    
    message: function() {
      $$('.message').each(function(message) {
        Event.observe(message, 'click', function() {
          message.hide();
        });
      });
    }
    
  }
}();

Event.observe(window, 'load', function() {
  Behaviours.labels();
  Behaviours.radioButtons();
  Behaviours.popup();
  Behaviours.message();
})

Ajax.Responders.register({
  onComplete: function() {
    Behaviours.labels();
    Behaviours.radioButtons();
  }
});
