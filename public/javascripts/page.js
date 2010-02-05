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
  width: 600,
  height: 495,
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
    
    //convert_urls: false,
    setup: initMceEditor
  }).toObject());
}

function swapOutImage(img) {
  var features = popupProps.map(function(pair) {
    return pair.key + '=' + pair.value;
  }).join(',');

  window.editedImage = img.up('.image');
  window.editedImg = img;
  window.imageAction = 'Swap Out';
  window.isSwapOut = true;
  window.open(tinyMCE.settings.new_image_path + '?type=only', '', features);
}

Event.observe(window, 'load', function() {
  $$('#images .image').each(function(image) {
    var img = image.down('img');
    adjustImage(image);
    adjustImageSize(img);
    Event.observe(img, 'click', swapOutImage.curry(img));
  });
});
