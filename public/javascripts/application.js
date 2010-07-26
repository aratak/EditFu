function createMessage(kind, text) {
  var message = null;
  if(text && !text.blank()) {
    message = $(document.createElement('span'));
    message.className = 'flash_' + kind;
    message.setStyle({ display: 'none' })
    message.innerHTML = text + "<a onclick='hideFlash($(this).up()); return false;' id='close_flash_" + kind + "' href='#' class='close'></a>"

    $('messages').insert({ top: message });
  }
  
  return message;
}

function showMessage(kind, text) {
  clearMessage();
  var message = createMessage(kind, text);
  if (message == null) { return null }
  appearMessage(message);
}

function showMessagesIcon() {
  if( $$('#messages span').length > 0 ) { 
    $('system-link-alert').show() 
    $('system-link-alert').pulsate({ pulses: 3, duration: 2 }).setOpacity('');
  }
}

function hideMessagesIcon() {
  if( $$('#messages span').length == 0 ) { 
    $('system-link-alert').fade() 
  }
}


function hideFlash(item) {
  $(item).setStyle({height: 'auto'}).show()
  $(item).down('.close').fade({ duration: 0.1 })
  $(item).slideUp('slow')
  
  showMessagesIcon();
}

function hideAllMessages() {
  $$('#messages span').each(function(item) {
    hideFlash(item);
  })
  
}


function showAllMessages() {
  $$('#messages span').each(function(item) {
    appearMessage(item);
  })
}

function appearMessage(idMessage) {
  var tmp = idMessage;
  $(idMessage).setStyle({ height: "auto" }).hide();
  $(idMessage).show('slow');
  $(idMessage).select('.close').invoke('appear', { duration: 0.3 })
  window.setTimeout(function() { 
    if( $(idMessage).visible() ) {
      hideFlash(tmp);
    }
  }, 7000);
  
}

function removeAllMessages() {
  $$('#messages span').invoke("remove");
  hideMessagesIcon()
}

function showBodyMessage(kind, text) {
  showMessage(kind, text);
}



function setTitle(newValue) {
  document.title = newValue;
  $$('#main .header .title')[0].innerHTML = newValue;
}

function clearMessage() {
  getActionBar().select('.message').invoke('remove');
}

function showConfirmPopup(href, question) {
  $('popup').innerHTML = $('confirm-popup').innerHTML;
  $('popup').down('a.yes').href = href;
  if(!question.blank()) {
    $('popup').down('.text').innerHTML = question;
  }
  showPopup();
}

function clearInputMessages() {
  clearMessage();
  $$('.error').invoke('remove');
}

function showInputMessage(inputId, message) {
  var input = $(inputId);
  if(input) {
    var row = input.up('.inputs-row');
    if(row && !row.down('.error')) {
      row.select('.label-input').each(function(i) {
        appendInputError(i, ' blank', '&nbsp;');
      });
    }

    appendInputError(input.up('.label-input'), '', message);
  }
}

function appendInputError(input, blank, message) {
  input.select('.error').invoke('remove');

  var div = $(document.createElement('div'));
  div.className = 'error' + blank;
  div.innerHTML = message;

  if (input.select('input')[0]) {
    input.select('input')[0].insert({before: div});
  } else {
    input.insert({top: div});
  }

}

function showPopup() {
  window.currentScrollOffsets = document.viewport.getScrollOffsets();
  document.documentElement.style.overflow = 'hidden';
  $('popup-system').show();
}

function hidePopup() {
  // document.documentElement.style.overflow = null;
  $$('body').invoke('setStyle', {overflow: ''});
  // $$('body').first().setStyle({ minHeight: "auto" });
  $('all').style.overflow = 'visible';
  $('popup-hider').up().fade({ duration: 0.2});
  $('popup').innerHTML = '';
  
  
  var left = 0;
  var top = 0;
  if(window.currentScrollOffsets != undefined) {
    left = window.currentScrollOffsets.left;
    top = window.currentScrollOffsets.top;
  }
  
  window.scrollTo(left, top);
  hideAllMessages();
  removeAllMessages();
}

function getActionBar() {
  
  var popupActionBars = $$('#popup .popup-action-bar');
  
  if(popupActionBars.size() > 1) {
    popupActionBars =  $$('#popup .active .popup-action-bar');
  }
  
  return popupActionBars.first() || $('action-bar');
}

function showProcessing(request) {
  clearMessage();
  var actionBar = getActionBar();
  if(actionBar) {
    var image = actionBar.down('.processing');
    if(image) {
      image.refCount++;
    } else {
      image = $(document.createElement('img'));
      image.refCount = 1;
      image.src = '/images/rotation.gif';
      image.className = 'processing';
      actionBar.insert({ bottom: image });
    }
    request.processing = image;
  }
}

function hideProcessing(request) {
  if(request.processing && --request.processing.refCount == 0) {
    request.processing.remove();
  }
}

// container = "div.plan-wrapper"
// element_class = "> div.plan-label"
function setElementsHeight(container, element_class ) {

  function getChildMaxHeight(element) {
    var maxHeight = 0;

    element.childElements().each(function(item) {
      var itemHeight = parseInt(item.getHeight());
      if(itemHeight > maxHeight) {maxHeight = itemHeight}
    });

    return maxHeight;
  }
  var maxHeight = getChildMaxHeight($$(container).first());

  $$(container).first().select(element_class).each(function(item) {
    item.setStyle({
      height: maxHeight + 'px'
    });
  });
}

function toggleEditor(id) {
  if (!tinyMCE.get(id)) {
    tinyMCE.execCommand('mceAddControl', false, id);
  } else {
    tinyMCE.execCommand('mceRemoveControl', false, id);
  }
}

var cardPreferencesDuration = 0.1;
var cardPreferencesButtonDuration = 0.3

function showCardForm() {
  if( $('billing_view') != null ) { $("billing_view").hide({ duration: cardPreferencesDuration }); }
  if (!$("billing_inputs").visible()) { $("billing_inputs").show({ duration: cardPreferencesDuration }); } 
  $$("#billing_inputs input").each(function(item) { $(item).enable(); })
}

function hideCardForm() {
  if( $('billing_view') != null ) {
    if (!$('billing_view').visible()) { $("billing_view").show({ duration: cardPreferencesDuration }); }
  }

  $$("#billing_inputs input").each(function(item) { $(item).disable(); })
  $("billing_inputs").hide({ duration: cardPreferencesDuration });
}

function cancelCardLinkState() {
  // $('cancel_card_link').appear({ duration: cardPreferencesButtonDuration });
}

function bindPlanAndCardForm() {
  
  $$('.plan input.payment:not(.current)').each(function(item) {
    $(item).observe('change', function(item) {
      $('change_card_link').fade({ duration: cardPreferencesButtonDuration });
    })
  })
  
  
  $$('.plan input:not(input.payment:not(.current))').each(function(item) {
    $(item).observe('change', function(item) {
      if($('cancel_card_link')) {
        $('change_card_link').appear({ duration: cardPreferencesButtonDuration });
      }
    })
  })
  
  $$('.plan input.unpayment').each(function(item) {
    $(item).observe('change', function(item) {
      if($('cancel_card_link')) {
        $('cancel_card_link').fade({ duration: cardPreferencesButtonDuration });
      }
    })
  })
  
  $$('.plan input:not(.unpayment)').each(function(item) {
    $(item).observe('change', function(item) {
      if($('cancel_card_link')) {
        $('cancel_card_link').appear({ duration: cardPreferencesButtonDuration });
      }
    })
  })
  
  
  $$('.plan input.current').each(function(item) {
    $(item).observe('change', function() { 
      hideCardForm() 
    })

    if ($(item).checked == true) {
      hideCardForm();
    }
  })
  
  
  $$('.plan input.unpayment').each(function(item) {
    $(item).observe('change', function() { 
      hideCardForm() 
      if( $('billing_view') != null ) { $("billing_view").hide({ duration: cardPreferencesDuration }); }
    })
  
    if ($(item).checked == true) {
      hideCardForm();
      if( $('billing_view') != null ) { $("billing_view").hide({ duration: cardPreferencesDuration }); }
    }
  })
  
  if( $('billing_view') == null ) {
    $$('input.payment').each(function(item) {
      $(item).observe('change', function() { 
        showCardForm();
      })
    })
  } else {
    $$('.plan input.not_current.payment').each(function(item) {
      $(item).observe('change', function() { 
        showCardForm();
      })
    })
  }
  
}



var observeAllForm = function() {
  
  $$('form').each(function(item) {
    new Form.Observer(item, 0.3, function(form, value){
      if($(this).down && $(this).down('input[type=submit]')) { $(form).down('input[type=submit]').addClassName('changed'); }
    })
  })
    
  $$('form').each(function(form) {
    $(form).observe('submit', function(item, form) {
      if($(this).down && $(this).down('input[type=submit]')) { $(this).down('input[type=submit]').removeClassName('changed'); }
    })
  })

}

var TinyMCEareaChanged = function(inst) {
  if($(this).down && $(this).down('input[type=submit]')) { inst.formElement.down('input[type=submit]').addClassName('changed'); }
}



Ajax.Responders.register({
  onCreate: showProcessing,
  
  onComplete: function(request, transport) {
    hideProcessing(request);
    bindPlanAndCardForm();
    observeAllForm();

    if(transport.status == 200) {
      var loc = transport.getHeader('X-Location');
      if(loc) {
        window.location = loc;
      }
    } 
    if(transport.status == 500) {
      createMessage('error', "Sorry, something went wrong. Please refresh your browser and try again. If this problem occurs again contact <a href='mailto:support@editfu.com'>support</a>.")
    } 
    
    
  }
});

Event.observe(window, 'load', function() {
  observeAllForm();
  var sourceBar = $('source-bar');
  if(sourceBar) {
    var selected = sourceBar.down('li.selected');
    if(selected) {
      sourceBar.scrollTop = selected.cumulativeOffset().top;
    }
  }
});


