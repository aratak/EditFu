function updateSectionImage(imageSrc) {
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
  tinyMCEPopup.close();
}

function updateStandaloneImage(src) {
  editedImage.image.src = tinyMCE.settings.site_url + '/' + src;
  editedImage.input.value = src;
  window.close();
}

function updateImage(src) {
  if(window.editedImage) {
    updateStandaloneImage(src);
  } else {
    updateSectionImage(src);
  }
}

function submitUploadForm() {
  if($F('uploadImage').blank()) {
    $('failure').innerHTML = 'Please select image.';
    return;
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
        updateImage(response.src);
      }
    }
  });

  return $('new_image_form').submit();
}

Event.observe(window, 'load', function() {
  $$('.tabs span').each(function(tab) {
    Event.observe(tab, 'click', function() {
      var id = tab.up('li').id;
      mcTabs.displayTab(id, id.sub('tab', 'panel'));
    });
  });

  $$('#images img').each(function(img) {
    Event.observe(img, 'click', function() {
      var src = img.src.substr(tinyMCE.settings.document_base_url.length);
      updateImage(src);
    });
  });

  Event.observe('uploadImage', 'change', submitUploadForm);
});
