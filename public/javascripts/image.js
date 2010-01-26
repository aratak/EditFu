function updateSection(imageSrc) {
  var ed = tinyMCEPopup.editor;
  var el = ed.selection.getNode();
  tinyMCEPopup.restoreSelection();

  if (!imageSrc) {
    if (el && el.nodeName == 'IMG') {
      ed.dom.remove(el);
      ed.execCommand('mceRepaint');
    }
  } else {
    if (el && el.nodeName == 'IMG') {
      ed.dom.setAttrib(el, 'src', imageSrc);
    } else {
      ed.execCommand('mceInsertContent', false, 
          '<img id="__mce_tmp" />', {skip_undo: 1});
      ed.dom.setAttrib('__mce_tmp', 'src', imageSrc);
      ed.dom.setAttrib('__mce_tmp', 'id', '');
      ed.undoManager.add();
    }
  }
}

function updateImage(src) {
  editedImage.image.src = tinyMCE.settings.site_url + '/' + src;
  editedImage.input.value = src;
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
        if(editedImage) {
          updateImage(response.src);
        } else {
          updateSection(response.src);
        }
        tinyMCEPopup.close();
      }
    }
  });

  return true;
}
