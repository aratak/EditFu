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
  var message = $('popup').down('.message') || $('page-message');
  message.hide();
  return message;
}

Ajax.Responders.register({
  onCreate: function() {
    showMessage('info', 'Processing request...');
  },

  onComplete: function() {
    clearMessage();
  }
});
