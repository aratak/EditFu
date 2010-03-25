$$("input[id^=pages_]").each(function(p) {
  p.disabled = true;
});

$$("input[id^=sites_]").each(function(s) {
  s.onclick = function() {
    $$("input[id^=pages_]").each(function(p) {
      if(p.up('.site').down('input') == s) {
        p.disabled = false;
      } else {
        p.checked = false;
        p.disabled = true;
      }
    });
  }
});

var form = $('downgrade-popup').down('form');
form.ajaxSubmit = form.onsubmit;
form.onsubmit = function() {
  if($$("input:checked[id^=pages_]").size() > 3) {
    showMessage('error', "You may choose at most 3 pages");
    return false;
  }
  return this.ajaxSubmit();
}
