function initThumbnail(img) {
  var maxSize = parseInt($(img).up().getStyle('width'), 10);

  img.originalHeight = img.height;
  img.originalWidth = img.width;

  if(img.height > img.width) {
    img.height = maxSize;
  } else {
    img.width = maxSize;
  }

  var thumbnail = img.up('.thumbnail');
  if(thumbnail) {
    thumbnail.style.visibility = 'visible';
  }
  img.onclick = selectImage.curry(img, false);
}

function selectImage(img, skipWarn) {
  $$('#thumbnails .thumbnail.selected').each(function(selected) {
    selected.removeClassName('selected');
  });
  img.up('.thumbnail').addClassName('selected');

  var src = decodeURIComponent(getImgPath(img));
  setImageInput('src', src);

  if(!skipWarn && window.isSwapOut) {
    var edited = window.editedImg;
    clearMessage();
    if(edited.originalHeight != img.originalHeight ||
       edited.originalWidth != img.originalWidth) {
      showMessage('warning', 
          'The chosen image is of different dimensions than the image your replacing. <br />' +
          'Be aware this can sometimes lead to design inconsistencies.');
    }
  }
}

function uploadImage() {
  $('popup').down('.fake-file .path').innerHTML = $F('image-file');
  if($F('image-file').blank()) {
    return;
  }

  var form = $('image-form');
  AjaxUpload.submit(form, {
    onStart: function() {
      showProcessing(form);
    },

    onComplete: function(response) {
      hideProcessing(form);

      var tmp = $(document.createElement('div'));
      tmp.innerHTML = response;
      var pre = tmp.down('pre');
      if(pre) {
        tmp.innerHTML = pre.innerHTML.unescapeHTML();
      }

      var thumbnail = tmp.down('.thumbnail');
      if(!thumbnail) {
        showMessage('error', 
          'There was error adding the image to EditFu. ' +
          'Please try again or review the ' + 
          '<a href="http://www.takeastep.me/editfu-faq/basics/" target="_blank">FAQ</a> ' +
          'for directions. <br> If this problem continues contact ' +
          '<a href="http://www.takeastep.me/editfu-contact-us/" target="_blank">support</a>');
      } else {
        showMessage('success', 'Image was added to EditFu successfully.');
        
        var img = thumbnail.down('img');
        img.onload = function() {
          initThumbnail(img);
          selectImage(img, false);
        };
        $('thumbnails').insert(thumbnail);
      }
    }
  });

  return $('image-form').submit();
}

function doImageAction() {
  var edited = window.editedImg;
  var src = $('image-form')['src'].value;

  if(!src.blank()) {
    if(!window.isSwapOut) {
      insertOrEditImage(edited);
    } else {
      var selected = $('thumbnails').down('.thumbnail.selected img');
      swapImage(edited, selected);
    }
    showMessage('success','Image was swapped successfully. Be sure to click publish to make the changes live.');
  }
  hidePopup();
}

function insertOrEditImage(edited) {
  var ed = window.editor;

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

function swapImage(edited, selected) {
  edited.alt = $('image-form')['alt'].value;
  if(!selected) {
    return;
  }

  if(edited.src == selected.src) {
    return;
  }

  window.editedImage.style.visibility = 'hidden';
  edited.removeAttribute('height');
  edited.removeAttribute('width');
  edited.style.width = null;
  edited.src = selected.src;

  $$('#image-form input[type="text"]').each(function(imageInput) {
    var selector = 'input[name*="' + imageInput.name + '"]';
    var pageInput = window.editedImage.down(selector);
    if (pageInput) {
      pageInput.value = imageInput.value;
    }
  });
}

function imagesPopupLoaded() {
  if(window.editedImg) {
    var editedPath = decodeURIComponent(getImgPath(window.editedImg));
    var editedUrl = tinyMCE.settings.document_base_url + editedPath;
    var editedImg = $('thumbnails').down('img[src="' + editedUrl + '"]');
    if(editedImg) {
      selectImage(editedImg, true);
    }
    setImageInput('src', editedPath);
    setImageInput('alt', window.editedImg.alt);
  }
}

function setImageInput(name, value) {
  var input = $($('image-form')[name]);
  setInputValue(input, value);
}

function getImgPath(img) {
  return img.src.sub(tinyMCE.settings.document_base_url, '');
}
