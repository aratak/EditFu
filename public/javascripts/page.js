function initMceEditor(ed) {
  ed.addCommand('efImage', function() {
      var el = ed.selection.getNode();
      // Internal image object like a flash placeholder
      if (el && ed.dom.getAttrib(el, 'class').indexOf('mceItem') != -1) {
        return;
      }

      var imageAction;
      if (!el || el.nodeName != 'IMG') {
        window.editedImg = null;
        imageAction = 'Insert';
      } else {
        window.editedImg = el;
        imageAction = 'Edit';
      }
      window.editor = ed;
      window.isSwapOut = false;

      loadImagePopup({type: 'content', imageAction: imageAction});
  });

  ed.addButton('image', { title: 'Add Image', cmd: 'efImage' });
}

function initTinyMCE(settings) {
  tinyMCE.init($H(settings).merge({
    mode: "textareas",
    theme: "advanced",
    skin: "editfu",
    theme_advanced_toolbar_location : "top",
    theme_advanced_buttons1: 
      'bold,italic,underline,strikethrough,formatselect,separator,' + 
      'undo,redo,separator,bullist,numlist,separator,image' + settings.code,
    theme_advanced_buttons2: "",
    theme_advanced_buttons3: "",
    theme_advanced_blockformats : "h1,h2,h3,h4,h5,h6",
    
    setup: initMceEditor
  }).toObject());
}

function swapOutImage() {
  window.editedImage = this;
  window.editedImg = this.down('img');
  window.isSwapOut = true;
  loadImagePopup({type: 'only', imageAction: 'Swap'});
}

function initImage(img) {
  var image = img.up('.image');

  img.originalHeight = img.height;
  img.originalWidth = img.width;

  if(img.width < 150) {
    img.width = 150;
  } else if(img.height > 641) {
    img.height = 641;
  }

  var bar = image.down('.bar');
  bar.innerHTML =  img.originalWidth + ' X ' + img.originalHeight;

  image.style.visibility = 'visible';
}

function loadImagePopup(parameters) {
  new Ajax.Request(tinyMCE.settings.new_image_path, { 
    method: "get", 
    parameters: parameters
  });
}

Event.observe(window, 'load', function() {
  var onsubmit = $('page-form').onsubmit;
  $('page-form').onsubmit = function() {
    tinyMCE.triggerSave();
    return onsubmit.apply(this);
  }

  $$('.image').each(function(image) {
    Event.observe(image, 'click', swapOutImage);
  });
});
