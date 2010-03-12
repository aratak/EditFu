var Behaviours = function() {
  return {

    labels: function() {
      $$('.label-input input').each(function(input) {
        Event.observe(input, 'blur', function() {
          input.addClassName('with-text');
        });
      });
      
      $$('.label-input input').each(function(input) {
        (input.getValue() == "") ? null : input.addClassName('with-text');
      });
      
      $$('.label-input input').each(function(input) {
        Event.observe(input, 'blur', function() {
          (input.getValue() == "") ? input.removeClassName('with-text') : null;
        })
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
        $(this).up().fade({ duration: 0.2})
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
  Behaviours.labels()
  Behaviours.radioButtons()
  Behaviours.popup()
  Behaviours.message()
})

Ajax.Responders.register({
  onComplete: function() {
    Behaviours.labels()
    Behaviours.radioButtons()
  }
});
