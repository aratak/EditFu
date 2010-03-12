// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function adjustImage(image) {
  var maxSize = parseInt(image.down('.thumbnail').getStyle('width'), 10);
  var img = image.down('img');

  img.originalHeight = img.height;
  img.originalWidth = img.width;

  if(img.height > img.width) {
    img.height = maxSize;
  } else {
    img.width = maxSize;
  }

  var size = image.down('.size');
  if(size) {
    size.innerHTML = img.originalHeight + 'x' + img.originalWidth;
  }

  var title = image.down('.title');
  if(title) {
    title.innerHTML = title.innerHTML.truncate(20);
  }

  image.style.visibility = 'visible';
}

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

/* TODO: maybe it should be removed */
function mainForm() {
  return $('main').down('form');
}

Event.observe(window, 'load', function() {
  
  
});

Ajax.Responders.register({
    onCreate: function() {
      showMessage('info', 'Processing request...');
    },
    onComplete: function() {
      clearMessage();
    }
});
