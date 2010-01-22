function savePageSections() {
  $('saveNotice').show();
  var form = $('update_form');
  form.commit.disable();

  tinyMCE.triggerSave();
  new Ajax.Request(form.action, {
    asynchronous: true,
    parameters: Form.serialize(form),
    onSuccess: function() {
      $('saveNotice').hide();
      form.commit.enable();
    }
  });
  return false;
}

function initMceEditor(ed) {
  ed.addCommand('efImage', function() {
      // Internal image object like a flash placeholder
      var selectionClass = ed.dom.getAttrib(ed.selection.getNode(), 'class');
      if (selectionClass.indexOf('mceItem') != -1) {
        return;
      }

      ed.windowManager.open({
        file: ed.settings.new_image_path,
        width: 300,
        height: 100,
        inline: 1
      });
  });

  ed.addButton('efImage', {
    title: 'Add Image',
    image: '/javascripts/tiny_mce/plugins/advimage/img/sample.gif',
    cmd: 'efImage'
  });
}

function initTinyMCE(settings) {
  tinyMCE.init($H(settings).merge({
    mode: "textareas",
    theme: "advanced",
    theme_advanced_buttons1: 
      'bold,italic,underline,strikethrough,separator,' + 
      'undo,redo,separator,bullist,numlist,separator,efImage',
    theme_advanced_buttons2: "",
    theme_advanced_buttons3: "",
    
    setup: initMceEditor
  }).toObject());
}
