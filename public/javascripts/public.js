
Event.observe(window, 'load', function() {

  var elements = $$('.hint:not(#comments)', 'label:not([for~=owner_terms_of_service])', 'div.label', '.description');
  elements.invoke('setStyle', { opacity: '0' });
  var move_count = 0;
  var visible = false;


  if ($$('input[type=text]', 'input[type=password]').size() > 0) {
    $$('input[type=text]', 'input[type=password]')[0].focus();
  }
  
  
  // if ($('owner_domain_name')) {
  //   
  //   $('owner_company_name').observe('keyup', function() {
  //     $('owner_domain_name').value = createDomainName( $('owner_company_name').value );
  //     setSameDomainInputWidth();
  //   })
  //   
  //   $('owner_domain_name').observe('keyup', setSameDomainInputWidth)
  // 
  //   $('owner_company_name').observe('click', function() {
  //     $('owner_domain_name').value = createDomainName( $('owner_company_name').value );
  //     setSameDomainInputWidth();
  //   })
  // 
  //   $('owner_company_name').observe('blur', function() {
  //     $('owner_domain_name').value = createDomainName( $('owner_company_name').value );
  //     setSameDomainInputWidth();
  //   })
  // 
  //   
  //   setSameDomainInputWidth();
  //   
  // }
  
  
  function createDomainName(val) {
    var q = new String(val);
    return q.replace(/\W/g, "")
  }
  
  function setSameDomainInputWidth() {
    $('fake_domain_name').innerHTML = $('owner_domain_name').value;
    $('owner_domain_name').setStyle({ width: $('fake_domain_name').getWidth()   + 'px' })
  }
  
  
  
  function appear() {
    if(move_count > 5 && !visible) {
      elements.each(function(element) {
        new Effect.Opacity(element,  { from: 0, to: 1, duration: 0.5 });
      })
      visible = true
    } else {
      move_count += 1
    }
  }
  
  
  $(document).observe('mousemove', appear)
  $(document).observe('click', appear)



});
