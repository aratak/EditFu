function getThumbnailPath(img) {
  return img.src.sub(tinyMCE.settings.document_base_url, '');
}

function selectImage(image) {
  $$('#images .image.selected').each(function(selected) {
    selected.removeClassName('selected');
  });
  image.addClassName('selected');

  $('url').value = decodeURIComponent(getThumbnailPath(image.down('img')));
}

function initImage(image) {
  adjustImage(image);
  Event.observe(image, 'click', function() {
    selectImage(image);
  });
}

function updateEditorImage(edited, path, alt) {
  var ed = tinyMCEPopup.editor;
  tinyMCEPopup.restoreSelection();

  if (edited) {
    ed.dom.setAttrib(edited, 'src', path);
    ed.dom.setAttrib(edited, 'alt', alt);
  } else {
    ed.execCommand('mceInsertContent', false, 
        '<img id="__mce_tmp" />', { skip_undo: 1 });
    ed.dom.setAttrib('__mce_tmp', 'src', path);
    ed.dom.setAttrib('__mce_tmp', 'alt', alt);
    ed.dom.setAttrib('__mce_tmp', 'id', '');
    ed.undoManager.add();
  }
}

function swapOutImage(edited, selected) {
  if(edited.originalHeight != selected.originalHeight ||
     edited.originalWidth != selected.originalWidth) {
    var s = confirm('Dimensions of original and new image are different ' +
      'so operation may cause display issues. Are you really want to proceed?');
    if(!s) {
      return;
    }
  }

  edited.src = selected.src;
  edited.setAttribute('height', selected.getAttribute('height'));
  edited.setAttribute('width', selected.getAttribute('width'));
  edited.originalHeight = selected.originalHeight;
  edited.originalWidth = selected.originalWidth;
  adjustImageSize(edited);
  window.opener.imageInput.value = getThumbnailPath(selected);
}

function updateImage() {
  var edited = window.opener.editedImage;
  if(!window.opener.isSwapOut) {
    var url = $F('url');
    if (!url.blank()) {
      updateEditorImage(edited, url, $F('alt'));
    }
  } else {
    var selected = $('images').down('.image.selected img');
    if(selected) {
      swapOutImage(edited, selected);
    }
  }
  tinyMCEPopup.close();
}

function submitUploadForm() {
  if($F('uploadImage').blank()) {
    return;
  }

  AjaxUpload.submit($('image_form'), {
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
        var img = image.down('img')
        img.onload = function() {
          initImage(image);
          selectImage(image);
        };
        $('images').insert(image);
      }
    }
  });

  return $('image_form').submit();
}

Event.observe(window, 'load', function() {
  $$('#images .image').each(initImage);
  Event.observe('uploadImage', 'change', submitUploadForm);

  Event.observe($('image_form'), 'submit', function() {
    updateImage();
    return false;
  });

  if(window.opener.editedImage) {
    var editedPath = decodeURIComponent(getThumbnailPath(window.opener.editedImage));
    var editedUrl = tinyMCE.settings.document_base_url + editedPath;
    var editedImg = $('images').down('img[src="' + editedUrl + '"]');
    if(editedImg) {
      selectImage(editedImg.up('.image'));
    }
    $('url').value = editedPath;
    $('alt').value = window.opener.editedImage.alt;
  }

  document.title = window.opener.imageAction + ' Image';
  $('submitButton').value = window.opener.imageAction;

  if(window.opener.isSwapOut) {
    $('url').disabled = true;
    $('alt').disabled = true;
  }
});
