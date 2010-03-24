Event.observe(window, "load", function() {
  $$("input[id^=sites_]").each(function(e) {
    e.onclick = onChangeSitePerm.bindAsEventListener();
  });
});

function onChangeSitePerm(evt) {
  var input = Event.element(evt);
  if(input.checked) {
    var siteId = input.id;
    $$("input." + siteId).each(function(i) {
      i.checked = true;
    });
  }
}
