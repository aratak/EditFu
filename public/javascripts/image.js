function updateEditorImage(path) {
  var ed = tinyMCEPopup.editor;
  var el = ed.selection.getNode();
  tinyMCEPopup.restoreSelection();

  if (el && el.nodeName == 'IMG') {
    ed.dom.setAttrib(el, 'src', path);
  } else {
    ed.execCommand('mceInsertContent', false, 
        '<img id="__mce_tmp" />', {skip_undo: 1});
    ed.dom.setAttrib('__mce_tmp', 'src', path);
    ed.dom.setAttrib('__mce_tmp', 'id', '');
    ed.undoManager.add();
  }
  tinyMCEPopup.close();
}

function updateStandaloneImage(path) {
  editedImage.image.src = tinyMCE.settings.site_url + '/' + path;
  editedImage.input.value = path;
  window.close();
}

function updateImage(path) {
  if(window.editedImage) {
    updateStandaloneImage(path);
  } else {
    updateEditorImage(path);
  }
}

function submitUploadForm() {
  if($F('uploadImage').blank()) {
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
      var path = img.src.substr(tinyMCE.settings.document_base_url.length);
      updateImage(path);
    });
  });
  Event.observe('uploadImage', 'change', submitUploadForm);

  $$('#images .title').each(function(title) {
    title.innerHTML = title.innerHTML.truncate(20);
  });
  resizeImages();
});
