var Indent = function() {

  var _javascriptTemplate = function(filename) {
    js_prefix = "/javascripts/"
    full_filename = js_prefix + filename + ".js"
    
    var e=window.document.createElement('script');
    e.setAttribute('src', full_filename);
    e.setAttribute('type', "text/javascript");
    return e 
  }

  var _stylesheetTemplate = function(filename) {
    css_prefix = "/stylesheets/"
    full_filename = css_prefix + filename + ".css"
    
    var e=window.document.createElement('link');
    e.setAttribute('href', full_filename);
    e.setAttribute('media', "screen");
    e.setAttribute('type', "text/css");
    e.setAttribute('rel', "stylesheet");
    return e
  }

  var _template = function(_type) {
    var templ = "";
    switch (_type)
    {
      case "javascript":
        templ = _javascriptTemplate
        break;
      case "stylesheet":
        templ = _stylesheetTemplate
        break;
    };

    return templ
  }  

  function includeAndIndent(_type, _filenames) {
    var result = [];
    var b = $$('head').first();

    for(i=0;i<_filenames.length;i++) {
      var content = _template(_type)(_filenames[i]);
      b.insert(content)
      console.log(b.innerHTML)
    }
  }

  // public 
  return {
    includeJavascript: function() {
      includeAndIndent("javascript", arguments);
    },
    includeStylesheet: function() {
      includeAndIndent("stylesheet", arguments);
    }
  };

}()







