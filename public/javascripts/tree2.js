var FtpTree = Class.create({
  imageFolder: '/images/tree2/',
  imageSuffix: '.png',
  closedImage: 'closed.png',
  openedImage: 'opened.png',

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
        var closedImg = $(document.createElement('img'));
        closedImg.className = 'closed';
        closedImg.src = tree.imageFolder + tree.closedImage;
        closedImg.onclick = tree.toggleFolder.bind(tree, li);
        li.insertBefore(closedImg, aTag);
      }

      var iconImg = document.createElement('img');
      iconImg.className = 'icon';
      iconImg.src = tree.getIconSrc(li);
      li.insertBefore(iconImg, aTag);
    });
  },

  onItemClick: function(li) {
    if (li.className == this.selectableClass) {
      this.onItemSelected(li);
      $('ftp-tree').select('span.selected').each(function(selected) {
        selected.removeClassName('selected');
        var icon = selected.up('li').down('.icon');
        icon.src = icon.src.sub('selected-', '');
      });
      li.down('span').addClassName('selected');
      var icon = li.down('.icon');
      icon.src = icon.src.replace(/([^\/]*)$/, 'selected-$1'); 
    }

    if (li.className == 'folder') {
      this.toggleFolder(li);
    }
  },

  toggleFolder: function(li) {
    var img = li.select('img.closed').first();
    if (!img || !img.visible()) return;

    var ul = li.select('ul').first();
    if (img.src.indexOf(this.closedImage) < 0) {
      img.src = img.src.replace(this.openedImage, this.closedImage);
      ul.style.display = 'none';
    } else {
      img.src = img.src.replace(this.closedImage, this.openedImage);
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
        showMessage('error', response.getHeader('ftp-error'));
        tree.parseResponse(li, response.responseText);
      },

      onFailure: function() {
        showMessage('error', 'Server error');
        tree.parseResponse(li, '');
      }
    });
  },

  parseResponse: function(li, responseText) {
    this.createBranch(li, responseText);
    if (li.select('li').size() == 0) {
      li.select('img.closed').each(function(closed) {
        closed.style.visibility = 'hidden';
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
  },

  getIconSrc: function(li) {
    var basename = li.className;
    if(basename == 'root') {
      basename = 'folder';
    }
    return this.imageFolder + basename + this.imageSuffix;
  }
});

// SiteFtpTree - for sites/new and sites/edit

var SiteFtpTree = Class.create(FtpTree, {
  selectableClass: 'folder',

  initialize: function() {
    var ul = this.createBranch(
      $('ftp-tree'),
      '<li class="root"><span>Root/</span></li>'
    );
    this.loadFolder(ul.select('li').first());
    $('ftp-tree').style.display = 'block';
  },

  onItemSelected: function(li) {
    $('site_site_root').value = this.getItemPath(li);
    $('site_site_root').fire('custom:change');
  },

  getRequestParams: function() {
    return $('site_form').serialize(true);
  }
});

SiteFtpTree.initForm = function() {
  $('site_server', 'site_login', 'site_password').each(function(input) {
      input.observe('change', function() {
        $('site_site_root').value = '';
        if($F('site_server') && $F('site_login') && $F('site_password')) {
          SiteFtpTree.show();
        } else {
          $('ftp-tree').hide();
        }
      });
  });
}

SiteFtpTree.show = function() {
  new SiteFtpTree();
}

// PageFtpTree - for pages/new

var PageFtpTree = Class.create(FtpTree, {
  selectableClass: 'file',

  initialize: function($super, site_id) {
    this.site_id = site_id;
    this.parseBranch($('ftp-tree').select('ul').first());

    $('ftp-tree').select('ul').each(function(ul) {
      ul.style.display = 'block';
    });
    $('ftp-tree').select('li.folder').each(function(li) {
      li.select('img.closed').first().remove();
    });

    var site_root = $('ftp-tree').select('li').last();
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
  $('ftp-tree').style.display = 'block';
}
