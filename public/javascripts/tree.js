var FtpTree = Class.create({
  imageFolder: '/images/tree/',
  imageSuffix: '.gif',
  plusImage: 'plus.gif',
  minusImage: 'minus.gif',

  createBranch: function(parentNode, html) {
    var ul = parentNode.select('ul').first();
    if (ul) {
      ul.remove();
    }

    ul = $(document.createElement('ul'));
    ul.style.display = 'block';
    ul.innerHTML = html;
    this.parseBranch(ul);
    parentNode.insert(ul);
    return ul;
  },

  parseBranch: function(branch) {
    var tree = this;
    branch.select('li').each(function(li) {
      var aTag = li.select('span').first();
      aTag.onclick = tree.onItemClick.bind(tree, li);

      if(li.className == tree.selectableClass) {
        aTag.className = 'selectable';
      }
      if(li.className == 'folder') {
        var plusImg = $(document.createElement('img'));
        plusImg.className = 'plus';
        plusImg.src = tree.imageFolder + tree.plusImage;
        plusImg.onclick = tree.toggleFolder.bind(tree, li);
        li.insertBefore(plusImg, aTag);
      }

      var iconImg = document.createElement('img');
      iconImg.src = tree.imageFolder + li.className + tree.imageSuffix;
      li.insertBefore(iconImg, aTag);
    });
  },

  onItemClick: function(li) {
    if (li.className == this.selectableClass) {
      this.onItemSelected(li);
      $('ftpTree').select('span.selected').each(function(selected) {
        selected.removeClassName('selected');
      });
      li.select('span').first().addClassName('selected');
    }

    if (li.className == 'folder') {
      this.toggleFolder(li);
    }
  },

  toggleFolder: function(li) {
    var img = li.select('img.plus').first();
    if (!img || !img.visible()) return;

    var ul = li.select('ul').first();
    if (img.src.indexOf(this.plusImage) < 0) {
      img.src = img.src.replace(this.minusImage, this.plusImage);
      ul.style.display = 'none';
    } else {
      img.src = img.src.replace(this.plusImage, this.minusImage);
      if (!ul) {
        this.loadFolder(li);
      } else {
        ul.style.display = 'block';
      }
    }
  },

  loadFolder: function(li) {
    this.createBranch(li, "<li class='load'><span>Loading...</span></li>");

    var tree = this;
    var params = this.getRequestParams();
    params['folder'] = this.getItemPath(li);
    new Ajax.Request('/sites/ls', {
      method: 'get',
      parameters: params,
      
      onSuccess: function(response) {
        $('failure').innerHTML = response.getHeader('ftp-error');
        tree.parseResponse(li, response.responseText);
      },

      onFailure: function() {
        $('failure').innerHTML = 'Server error';
        tree.parseResponse(li, '');
      }
    });
  },

  parseResponse: function(li, responseText) {
    this.createBranch(li, responseText);
    if (li.select('li').size() == 0) {
      li.select('img.plus').each(function(plus) {
        plus.style.visibility = 'hidden';
      });
    }
  },

  getItemPath: function(li, relative) {
    var names = [];
    li.childElements().first().ancestors().each(function(folder) {
      if (folder.tagName == 'LI') {
        if(folder.className == 'root') {
          throw $break;
        } else {
          names.push(folder.select('span').first().innerHTML);
        }
      }
    });
    return '/' + names.reverse().join('/');
  }
});

// SiteFtpTree - for sites/new and sites/edit

var SiteFtpTree = Class.create(FtpTree, {
  selectableClass: 'folder',

  initialize: function() {
    var ul = this.createBranch(
      $('ftpTree'),
      '<li class="root"><span>' + $F('site_server') + '</span></li>'
    );
    this.loadFolder(ul.select('li').first());
    $('ftpTree').style.display = 'block';
  },

  onItemSelected: function(li) {
    $('site_site_root').value = this.getItemPath(li);
  },

  getRequestParams: function() {
    return $('site_form').serialize(true);
  }
});

SiteFtpTree.initForm = function() {
  $('site_server', 'site_login', 'site_password').each(function(input) {
      input.observe('change', function() {
        $('ftpTree').hide();
      });
  });
}

SiteFtpTree.show = function() {
  var names = ['server', 'login', 'password'];
  for(var i = 0; i < names.length; i++) {
    if(!$F('site_' + names[i])) {
      $('failure').innerHTML = names[i].capitalize() + " can't be blank";
      return;
    }
  }

  $('failure').innerHTML = '';
  new SiteFtpTree();
}

// PageFtpTree - for pages/new

var PageFtpTree = Class.create(FtpTree, {
  selectableClass: 'file',

  initialize: function($super, site_id) {
    this.site_id = site_id;
    this.parseBranch($('ftpTree').select('ul').first());

    $('ftpTree').select('ul').each(function(ul) {
      ul.style.display = 'block';
    });
    $('ftpTree').select('li.folder').each(function(li) {
      li.select('img.plus').first().remove();
    });

    var site_root = $('ftpTree').select('li').last();
    this.root_path = this.getItemPath(site_root);
    this.loadFolder(site_root);

    $super();
  },

  onItemSelected: function(li) {
    $('page_path').value = this.getItemPath(li).sub(this.root_path + '/', '');
  },

  getRequestParams: function() {
    return { site_id: this.site_id }
  }
});

PageFtpTree.show = function() {
  $('ftpTree').style.display = 'block';
}
