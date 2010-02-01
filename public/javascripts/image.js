function getThumbnailPath(img) {
  return img.src.substr(tinyMCE.settings.document_base_url.length);
}

function updateEditorImage(img) {
  var path = getThumbnailPath(img);
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

function updateStandaloneImage(img) {
  editedImage.image.src = img.src;
  editedImage.image.height = img.height;
  editedImage.image.width = img.width;
  editedImage.input.value = getThumbnailPath(img);
  window.close();
}

function updateImage(img) {
  if(window.editedImage) {
    updateStandaloneImage(img);
  } else {
    updateEditorImage(img);
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

    onComplete: function(response) {
      $('processing').hide();
      if(response.blank()) {
        $('failure').innerHTML = 'Server error';
      } else {
        var tmp = $(document.createElement('div'));
        tmp.innerHTML = response;

        var image = tmp.down();
        image.down('img').onload = function() {
          adjustImage(image);
          updateImage(image.down('img'));
        };
        $('images').insert(image);
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
  $$('#images .image').each(function(image) {
    var img = image.down('img');
    adjustImage(image);
    Event.observe(img, 'click', function() {
      updateImage(img);
    });
  });
  Event.observe('uploadImage', 'change', submitUploadForm);

  $$('#images .title').each(function(title) {
    title.innerHTML = title.innerHTML.truncate(20);
  });
});
