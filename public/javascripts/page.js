function doUpdate() {
  tinyMCE.triggerSave();
  showMessage('info', 'Saving page...');
  mainForm().request({
    onSuccess: function() {
      showMessage('success', 'Your changes were updated successfully.');
    }
  });
  return false;
}

var popupProps = $H({
  width: 900,
  height: 575,
  resizable: 'no',
  scrollbars: 'no'
});

function initMceEditor(ed) {
  ed.addCommand('efImage', function() {
      var el = ed.selection.getNode();
      // Internal image object like a flash placeholder
      if (el && ed.dom.getAttrib(el, 'class').indexOf('mceItem') != -1) {
        return;
      }

      if (!el || el.nodeName != 'IMG') {
        window.editedImg = null;
        window.imageAction = 'Insert';
      } else {
        window.editedImg = el;
        window.imageAction = 'Edit';
      }
      window.isSwapOut = false;

      var url = ed.settings.new_image_path + '?type=content';
      ed.windowManager.open(
        popupProps.merge({file: url}).toObject()
      );
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
      'bold,italic,underline,strikethrough,separator,' + 
      'undo,redo,separator,bullist,numlist,separator,image',
    theme_advanced_buttons2: "",
    theme_advanced_buttons3: "",
    
    //convert_urls: false,
    setup: initMceEditor
  }).toObject());
}

function swapOutImage() {
  var features = popupProps.map(function(pair) {
    return pair.key + '=' + pair.value;
  }).join(',');

  window.editedImage = this;
  window.editedImg = this.down('img');
  window.imageAction = 'Swap';
  window.isSwapOut = true;
  window.open(tinyMCE.settings.new_image_path + '?type=only', '', features);
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
  bar.innerHTML = img.originalHeight + ' X ' + img.originalWidth;

  image.style.visibility = 'visible';
}

Event.observe(window, 'load', function() {
  $$('.image').each(function(image) {
    Event.observe(image, 'click', swapOutImage);
  });
});
