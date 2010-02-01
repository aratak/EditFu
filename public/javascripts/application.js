// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function adjustImage(image) {
  var maxSize = parseInt(image.down('.thumbnail').getStyle('width'), 10);
  var img = image.down('img');

  img.originalHeight = img.height;
  img.originalWidth = img.width;

  if(img.height > img.width) {
    img.height = maxSize;
  } else {
    img.width = maxSize;
  }

  var title = image.down('.title');
  if(title) {
    title.innerHTML = title.innerHTML.truncate(20);
  }

  image.style.visibility = 'visible';
}
