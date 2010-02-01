function savePageSections() {
  $('saveNotice').show();
  var form = $('update_form');
  form.commit.disable();

  tinyMCE.triggerSave();
  form.request({
    onSuccess: function() {
      $('saveNotice').hide();
      form.commit.enable();
    }
  });
  return false;
}

var popupProps = $H({
  width: 500,
  height: 300
});

function initMceEditor(ed) {
  ed.addCommand('efImage', function() {
      // Internal image object like a flash placeholder
      var selectionClass = ed.dom.getAttrib(ed.selection.getNode(), 'class');
      if (selectionClass.indexOf('mceItem') != -1) {
        return;
      }

      ed.windowManager.open(
        popupProps.merge({file: ed.settings.new_image_path}).toObject()
      );
  });

  ed.addButton('image', {
    title: 'Add Image',
    cmd: 'efImage'
  });
}

function initTinyMCE(settings) {
  tinyMCE.init($H(settings).merge({
    mode: "textareas",
    theme: "advanced",
    theme_advanced_buttons1: 
      'bold,italic,underline,strikethrough,separator,' + 
      'undo,redo,separator,bullist,numlist,separator,image',
    theme_advanced_buttons2: "",
    theme_advanced_buttons3: "",
    
    setup: initMceEditor
  }).toObject());
}

function swapOutImage(img) {
  var features = popupProps.map(function(pair) {
    return pair.key + '=' + pair.value;
  }).join(',');
  var popup = window.open(tinyMCE.settings.new_image_path, '', features);
  popup.editedImage = {
    image: img,
    input: img.up().next('input')
  };
}

Event.observe(window, 'load', function() {
  $$('#images .image').each(function(image) {
    var img = image.down('img');
    adjustImage(image);
    Event.observe(img, 'click', swapOutImage.curry(img));
  });
});
