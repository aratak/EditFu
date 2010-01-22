function updateImage(src) {
  var ed = tinyMCEPopup.editor;
  var el = ed.selection.getNode();
  tinyMCEPopup.restoreSelection();

  if (!src) {
    if (el && el.nodeName == 'IMG') {
      ed.dom.remove(el);
      ed.execCommand('mceRepaint');
    }
  } else {
    if (el && el.nodeName == 'IMG') {
      ed.dom.setAttrib(el, args);
    } else {
      ed.execCommand('mceInsertContent', false, 
          '<img id="__mce_tmp" />', {skip_undo: 1});
      ed.dom.setAttrib('__mce_tmp', 'src', src);
      ed.dom.setAttrib('__mce_tmp', 'id', '');
      ed.undoManager.add();
    }
  }
  tinyMCEPopup.close();
}

function submitForm() {
  if($F('image').blank()) {
    $('failure').innerHTML = 'Please select image.';
    return false;
  }

  AjaxUpload.submit($('new_image_form'), {
    onStart: function() {
      $('failure').innerHTML = '';
      $('processing').show();
    },

    onComplete: function(responseText) {
      var response = responseText.evalJSON();
      if(response.error) {
        $('failure').innerHTML = 'Server error';
      } else {
        $('success').innerHTML = 'Good work.';
        updateImage(response.src);
      }
    }
  });

  return true;
}
