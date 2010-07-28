function badBrowser(){
  // Bad browser if
  // Firefox < 3 .0
  // Opera < 9
  // Safari < 4
  // Google Chrome < 3.0
  // MSIE < 8.0

  var userAgent = navigator.userAgent.toLowerCase();
  Prototype.Browser.Chrome = /chrome/.test(navigator.userAgent.toLowerCase());
  Prototype.Browser.Safari = !Prototype.Browser.Chrome && Prototype.Browser.WebKit;

  // Is this a version of IE?
  if(Prototype.Browser.IE){
    version = parseInt(userAgent.substring(userAgent.indexOf("msie")+5))
    if(version < 8) { return true; }
  }

  // Is this a version of Chrome?
  if(Prototype.Browser.Chrome){
    userAgent = userAgent.substring(userAgent.indexOf('chrome/') +7);
    userAgent = userAgent.substring(0,userAgent.indexOf('.'));	
    version = userAgent;
    if(version < 3) { return true; }
  }

  // Is this a version of Safari?
  if(Prototype.Browser.Safari){
    userAgent = userAgent.substring(userAgent.indexOf('version/') +8);	
    userAgent = userAgent.substring(0,userAgent.indexOf('.'));
    version = userAgent;	
    if(version < 4) { return true; }
  }

  // Is this a version of Mozilla?
  if(Prototype.Browser.Gecko){
  //Is it Firefox?
    if(userAgent.indexOf('firefox') != -1){
      userAgent = userAgent.substring(userAgent.indexOf('firefox/') +8);
      userAgent = userAgent.substring(0,userAgent.indexOf('.'));
      version = userAgent;
      if(version < 2) { return true; }
    }
  }
  // If not then it must be another Mozilla

  // Is this a version of Opera?
  if(Prototype.Browser.Opera){
    userAgent = userAgent.substring(userAgent.indexOf('version/') +8);
    userAgent = userAgent.substring(0,userAgent.indexOf('.'));
    version = userAgent;
    if(version < 9) { return true; }
  }
  return false;
}

Event.observe(window, 'load', function() {
  if(badBrowser()) {
    $('popup-system').show();
    $$('.cancel')[0].observe('click', function() {
      $('popup-system').hide();
      return false;
    }); 
  }
});

