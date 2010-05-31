
Event.observe(window, 'load', function() {

  var elements = $$('.hint', 'label:not([for~=owner_terms_of_service])', 'div.label', '.description');
  elements.invoke('setStyle', { opacity: '0' });
  var move_count = 0;
  var visible = false;
  
  $$('input[type=text]', 'input[type=password]')[0].focus();
  
  
  $(document).observe('mousemove', function() {
    if(move_count > 5 && !visible) {
      elements.each(function(element) {
        new Effect.Opacity(element,  { from: 0, to: 1, duration: 0.5 });
      })
      visible = true
    } else {
      move_count += 1
    }
  })



});
