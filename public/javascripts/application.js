// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function showMessage(kind, text) {
  var message = clearMessage();
  if(text && !text.blank()) {
    var d = document.createElement('div');
    d.className = kind;
    d.innerHTML = text;
  
    message.update(d);
    message.show();
    message.effect = new Effect.Fade(message, {delay: 10, duration: 5});
  }
}

function clearMessage() {
  var message = $$('popup.message').first() || $('page-message');
  if(message.effect) {
    message.effect.cancel();
  }
  message.setOpacity(1.0);
  message.hide();
  return message;
}

function showConfirmPopup(href) {
  $('popup').innerHTML = $('confirm-popup').innerHTML;
  $('popup').down('a.yes').href = href;
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
  input.insert({top: div});
}

function showPopup() {
  $('popup-system').show();
  $('popup-system').scrollTo();
}

function hidePopup() {
  $('all').style.overflow = 'visible';
  $('popup-hider').up().fade({ duration: 0.2});
  $('popup').innerHTML = '';
}

Ajax.Responders.register({
  onCreate: function(request) {
    clearMessage();
    var actionBar = $$('#popup .popup-action-bar').first() || $('action-bar')
    if(actionBar && !actionBar.down('.processing')) {
      var image = $(document.createElement('img'));
      image.src = '/images/rotation.gif';
      image.className = 'processing';
      actionBar.insert({ bottom: image });
      request.processing = image;
    }
  },

  onComplete: function(request, transport) {
    if(request.processing) {
      request.processing.remove();
    }

    if(transport.status == 200) {
      var loc = transport.getHeader('X-Location');
      if(loc) {
        window.location = loc;
      }
    }
  }
});
