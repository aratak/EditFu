function setInputValue(input, value) {
  toggleInputClass(input, value);
  input.value = value;
}

function hideFlash(item) {
  // $(item).up().hide()
  var action = function() {
    $(item).up().morph('height: 0; display: none;')
  }
  
  action()
}

// function toggleInputClass(input, value) {
//   if(!value) {
//     value = input.getValue();
//   }
//   value = value || '';
//   
//   if(value.blank()) {
//     input.removeClassName('with-text');
//   } else {
//     input.addClassName('with-text');
//   }
// }

var Behaviours = function() {
  return {

    // labels: function() {
    //   $$('.label-input input').each(function(input) {
    //     Event.observe(input, 'blur', function() {
    //       toggleInputClass(input);
    //       if(input.name.include('email')) {
    //         $$('.label-input input[type=password]').each(function(pinput) {
    //           toggleInputClass(pinput);
    //         });
    //       }
    //     });
    //   });
    //   
    //   $$('.label-input input').each(function(input) {
    //       toggleInputClass(input);
    //   });
    // 
    //   new PeriodicalExecuter(function(pe) {
    //     pe.stop();
    //     $$('.label-input input').each(function(input) {
    //         toggleInputClass(input);
    //     });
    //   }, 0.5);
    // },
    
    labels: function() {
      // $$('.inputs-row').each(function(item){
      //   console.log( $(item).down('.label-input .fieldWithErrors') )
      // })
      
      $$('.fieldWithErrors').each(function(item) {
        // var h = $(item).getHeight()
        $(item).up('.inputs-row').select('.title-input > .label-input > input').invoke('setStyle', {position: 'relative', top: '30px'})
        
        // .each(function(item) {
        //   console.log( $(item) )
        // })
      })
      
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
  Behaviours.message();
})

Ajax.Responders.register({
  onComplete: function() {
    Behaviours.labels();
    Behaviours.radioButtons();
    Behaviours.message();
  }
});
