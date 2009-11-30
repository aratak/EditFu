tinyMCE.init({
  mode : "textareas",
  theme : "simple"
});

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
