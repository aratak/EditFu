function showImagePopup(ed) {
  var el = ed.selection.getNode();
  // Internal image object like a flash placeholder
  if (el && ed.dom.getAttrib(el, 'class').indexOf('mceItem') != -1) {
    return;
  }

  var imageAction;
  if (!el || el.nodeName != 'IMG') {
    window.editedImg = null;
    imageAction = 'Insert';
  } else {
    window.editedImg = el;
    imageAction = 'Edit';
  }
  window.editor = ed;
  window.isSwapOut = false;

  loadImagePopup({type: 'content', imageAction: imageAction});
}

function showHtmlCodePopup(ed) {
  $('popup').innerHTML = $('code-popup-template').innerHTML;

  if (tinymce.isGecko) {
    document.body.spellcheck = ed.getParam("gecko_spellcheck");
  }

  var input = $('popup').down('textarea');
  input.value = ed.getContent({source_view : true});
  input.ed = ed;
  showPopup();
}

function updateHtmlCode() {
  var input = $('popup').down('textarea');
  input.ed.setContent(input.value, {source_view : true});
  hidePopup();
}

function initMceEditor(ed) {
  ed.addCommand('efImage', function() { 
    showImagePopup(ed); 
  });
  ed.addButton('image', { title: 'Add Image', cmd: 'efImage' });

  ed.addCommand('efCode', function() {
    showHtmlCodePopup(ed);
  });
  ed.addButton('code', { title: 'HTML code', cmd: 'efCode' });
}

function editfuMceLayout(s, tb, o) {
  var DOM = tinymce.DOM;
  var ed = this, t = ed.theme, cf = ed.controlManager, to;
  var tr = DOM.add(tb, 'tr');

  var createToolbar = function (buttons, align) {
    var td = DOM.add(tr, 'td', {'class' : 'mceToolbar mce' + align});
    to = cf.createToolbar("toolbar" + align);
    t._addControls(buttons, to);
    DOM.setHTML(td, to.renderHTML());
  }
  createToolbar('undo,redo', 'Left');
  createToolbar('formatselect,bold,italic,underline,bullist,numlist', 'Center');
  createToolbar('image' + s.code, 'Right');
  o.deltaHeight -= s.theme_advanced_row_height;

  tr = DOM.add(tb, 'tr');
  td = DOM.add(tr, 'td', {'class' : 'mceIframeContainer', 'colspan' : '3'});
  return td;
}

function initTinyMCE(settings) {
  tinyMCE.init($H(settings).merge({
    mode: "textareas",
    editor_selector: 'mce_area',
    theme: "advanced",
    skin: "editfu",
    theme_advanced_layout_manager: "CustomLayout",
    theme_advanced_custom_layout : editfuMceLayout,
    theme_advanced_blockformats : "h1,h2,h3,h4,h5,h6",
    setup: initMceEditor
  }).toObject());
}

function swapOutImage() {
  window.editedImage = this;
  window.editedImg = this.down('img');
  window.isSwapOut = true;
  loadImagePopup({type: 'only', imageAction: 'Swap'});
}

function initImage(img) {
  var image = img.up('.image');

  img.originalHeight = img.height;
  img.originalWidth = img.width;

  if(img.width < 150) {
    img.width = 150;
  } else {
    img.style.width='100%';
    if(img.height > 641) {
      img.height = 641;
    }
  }

  var bar = image.down('.bar');
  bar.innerHTML =  img.originalWidth + ' X ' + img.originalHeight;

  image.style.visibility = 'visible';
}

function loadImagePopup(parameters) {
  new Ajax.Request(tinyMCE.settings.new_image_path, { 
    method: "get", 
    parameters: parameters
  });
}

Event.observe(window, 'load', function() {
  var onsubmit = $('page-form').onsubmit;
  $('page-form').onsubmit = function() {
    tinyMCE.triggerSave();
    return onsubmit.apply(this);
  }

  $$('.image').each(function(image) {
    Event.observe(image, 'click', swapOutImage);
  });
});
