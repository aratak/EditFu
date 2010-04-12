function showMessage(kind, text) {
  clearMessage();
  if(text && !text.blank()) {
    var message = $(document.createElement('div'));
    message.className = 'message ' + kind;
    message.innerHTML = text;
  
    getActionBar().insert({top: message });
    message.effect = new Effect.Fade(message, {delay: 10, duration: 5});
  }
}

function clearMessage() {
  getActionBar().select('.message').invoke('remove');
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

function getActionBar() {
  return $$('#popup .popup-action-bar').first() || $('action-bar');
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

Ajax.Responders.register({
  onCreate: showProcessing,

  onComplete: function(request, transport) {
    hideProcessing(request);

    if(transport.status == 200) {
      var loc = transport.getHeader('X-Location');
      if(loc) {
        window.location = loc;
      }
    }
  }
});

Event.observe(window, 'load', function() {
  var sourceBar = $('source-bar');
  if(sourceBar) {
    var selected = sourceBar.down('li.selected');
    if(selected) {
      sourceBar.scrollTop = selected.cumulativeOffset().top;
    }
  }
});
