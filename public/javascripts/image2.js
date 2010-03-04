function initThumbnail(img) {
  var maxSize = parseInt($(img).up().getStyle('width'), 10);

  img.originalHeight = img.height;
  img.originalWidth = img.width;

  if(img.height > img.width) {
    img.height = maxSize;
  } else {
    img.width = maxSize;
  }

  img.up('.thumbnail').style.visibility = 'visible';
  img.onclick = selectImage.curry(img);
}

function selectImage(img) {
  $$('#thumbnails .thumbnail.selected').each(function(selected) {
    selected.removeClassName('selected');
  });
  img.up('.thumbnail').addClassName('selected');

  var src = decodeURIComponent(getImgPath(img));
  setImageInput('src', src);
}

function uploadImage() {
  this.up().down('.path').innerHTML = this.value;
  if(this.value.blank()) {
    return;
  }

  AjaxUpload.submit($(this.form), {
    onStart: function() {
      showMessage('info', 'Uploading image to the server...');
    },

    onComplete: function(response) {
      clearMessage();

      if(response.blank()) {
        showMessage('error', 'Server error');
      } else {
        showMessage('success', 'Image was successfully uploaded.');

        var tmp = $(document.createElement('div'));
        tmp.innerHTML = response;
        
        var img = tmp.down('img');
        img.onload = function() {
          initThumbnail(img);
          selectImage(img);
        };
        $('thumbnails').insert(tmp.down());
      }
    }
  });

  return $('image-form').submit();
}

function doImageAction() {
  var edited = window.opener.editedImg;
  var selected = $('thumbnails').down('.thumbnail.selected img');
  insertOrEditImage(edited, selected);
  tinyMCEPopup.close();
}

Event.observe(window, 'load', function() {
  Event.observe('uploadImage', 'change', uploadImage);

  if(window.opener.editedImg) {
    var editedPath = decodeURIComponent(getImgPath(window.opener.editedImg));
    var editedUrl = tinyMCE.settings.document_base_url + editedPath;
    var editedImg = $('thumbnails').down('img[src="' + editedUrl + '"]');
    if(editedImg) {
      selectImage(editedImg);
    }
    setImageInput('src', editedPath);
    setImageInput('alt', window.opener.editedImg.alt);
  }

  var popup = $('image-popup');
  popup.down('h1').innerHTML  = document.title = 
    window.opener.imageAction + ' Image';
  popup.down('.action-bar').down('.save').innerHTML = window.opener.imageAction;
});

function insertOrEditImage(edited, selected) {
  var ed = tinyMCEPopup.editor;
  tinyMCEPopup.restoreSelection();

  var src = $('image-form')['src'].value;
  var alt = $('image-form')['alt'].value;
  if (edited) {
    ed.dom.setAttrib(edited, 'src', src);
    ed.dom.setAttrib(edited, 'alt', alt);
  } else {
    ed.execCommand('mceInsertContent', false, 
        '<img id="__mce_tmp" />', { skip_undo: 1 });
    ed.dom.setAttrib('__mce_tmp', 'src', src);
    ed.dom.setAttrib('__mce_tmp', 'alt', alt);
    ed.dom.setAttrib('__mce_tmp', 'id', '');
    ed.undoManager.add();
  }
}

function setImageInput(name, value) {
  var input = $($('image-form')[name]);
  input.value = value;
  input.up().down('.label').innerHTML = value;
}

function getImgPath(img) {
  return img.src.sub(tinyMCE.settings.document_base_url, '');
}
