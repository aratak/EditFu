function initThumbnail(img) {
  var maxSize = parseInt($(img).up().getStyle('width'), 10);

  img.originalHeight = img.height;
  img.originalWidth = img.width;

  if(img.height > img.width) {
    img.height = maxSize;
  } else {
    img.width = maxSize;
  }
  img.style.visibility = 'visible';
}

function uploadImage() {
  this.up('.input').down('.path').innerHTML = this.value;
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
        $('thumbnails').insert(response);
      }
    }
  });

  return $('image_form').submit();
}

Event.observe(window, 'load', function() {
  Event.observe('uploadImage', 'change', uploadImage);
});
