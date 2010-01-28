// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function resizeImages() {
  $$('#images img').each(function(img) {
    var maxSize = img.up().getWidth();
    var height = img.height, width = img.width;
    if(img.height > img.width) {
      img.height = maxSize;
    } else {
      img.width = maxSize;
    }
  });
  $('images').style.visibility = 'visible';
}
