var FtpTree = Class.create({
  imageFolder: '/images/tree2/',
  imageSuffix: '.png',
  closedImage: 'closed.png',
  openedImage: 'opened.png',

  initialize: function(site_id) {
    this.site_id = site_id;
    this.root = this.appendNode($('ftp-tree'), "root", "Root/");
  },

  appendBranch: function(parentNode, html) {
    var ul = parentNode.down('ul');
    if (ul) {
      ul.remove();
    }

    ul = $(document.createElement('ul'));
    ul.style.display = 'block';
    ul.innerHTML = html;
    this.initBranch(ul);
    parentNode.insert(ul);
    return ul;
  },

  appendNode: function(parentNode, type, title) {
    var html = '<li class="#{type}"><span>#{title}</span></li>'.interpolate({
      type: type, title: title
    });
    return this.appendBranch(parentNode, html).down('li');
  },

  initBranch: function(branch) {
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
      this.markSelected(li);
    }

    if (li.className == 'folder') {
      this.toggleFolder(li);
    }
  },

  markSelected: function(li) {
    $('ftp-tree').select('span.selected').each(function(selected) {
      selected.removeClassName('selected');
      var icon = selected.up('li').down('.icon');
      icon.src = icon.src.sub('selected-', '');
    });

    li.down('span').addClassName('selected');
    var icon = li.down('.icon');
    icon.src = icon.src.replace(/([^\/]*)$/, 'selected-$1'); 
  },

  toggleFolder: function(li) {
    var img = li.down('img.closed');
    if (!img || !img.visible()) return;

    if (img.src.indexOf(this.closedImage) < 0) {
      this.collapseFolder(li);
    } else {
      this.expandFolder(li);
    }
  },

  expandFolder: function(li) {
    var img = li.down('img.closed');
    if(img) {
      img.src = img.src.replace(this.closedImage, this.openedImage);
    }

    var ul = li.down('ul');
    if (!ul) {
      this.loadList(li);
    } else {
      ul.style.display = 'block';
    }
  },

  collapseFolder: function(li) {
    var img = li.down('img.closed');
    img.src = img.src.replace(this.openedImage, this.closedImage);
    li.down('ul').style.display = 'none';
  },

  expandTree: function(li) {
    var tree = this;
    li.select('li.folder ul').each(function(ul) {
      tree.expandFolder(ul.up('li.folder'));
    });
  },

  loadList: function(li) {
    var params = this.getRequestParams();
    params['folder'] = this.getItemPath(li);
    this.loadData(li, 'ls', params);
  },

  loadTree: function(li) {
    var tree = this;
    this.loadData(li, 'tree', { site_id: this.site_id }, function() {
      tree.expandTree(li);
      var path = $F('site_site_root').substr(1);
      var selected = tree.findItem(li, path);
      if(selected) {
        tree.markSelected(selected);
      } else {
        showMessage('error', "Site root isn't exist on the server.");
      }
    });
  },

  loadData: function(li, method, params, callback) {
    this.appendBranch(li, "<li class='load'><span>Loading...</span></li>");

    var tree = this;
    new Ajax.Request('/sites/' + method, {
      method: 'get',
      parameters: params,
      
      onSuccess: function(response) {
        var error = response.getHeader('ftp-error');
        showMessage('error', error);
        tree.parseResponse(li, response.responseText);
        if(!error && callback) {
          callback();
        }
      },

      onFailure: function() {
        showMessage('error', 'Server error');
        tree.parseResponse(li, '');
      }
    });
  },

  parseResponse: function(li, responseText) {
    this.appendBranch(li, responseText);
    if (li.select('li').size() == 0) {
      li.select('img.closed').each(function(closed) {
        closed.style.visibility = 'hidden';
      });
    }
  },

  getItemPathTo: function(li, ancestor) {
    var names = [];
    li.childElements().first().ancestors().each(function(folder) {
      if (folder.tagName == 'LI') {
        if(folder == ancestor) {
          throw $break;
        } else {
          names.push(folder.select('span').first().innerHTML);
        }
      }
    });
    return names.reverse().join('/');
  },

  getItemPath: function(li) {
    return '/' + this.getItemPathTo(li, this.root);
  },

  findItem: function(li, relativePath) {
    relativePath.match(/([^\/]*)\/?(.*)/);
    var name = RegExp.$1;
    var rest = RegExp.$2;

    var child = li.down('ul').childElements().find(function(e) {
      return e.down('span').innerHTML == name;
    });

    if(!rest || !child) {
      return child;
    } else {
      return this.findItem(child, rest);
    }
  },

  getIconSrc: function(li) {
    var basename = li.className;
    if(basename == 'root') {
      basename = 'folder';
    }
    return this.imageFolder + basename + this.imageSuffix;
  },

  getRoot: function() {
    return $('ftp-tree').down('li');
  }
});

// SiteFtpTree - for sites/new and sites/edit

var SiteFtpTree = Class.create(FtpTree, {
  selectableClass: 'folder',

  initialize: function($super, site_id) {
    $super(site_id);

    if(this.site_id) {
      this.loadTree(this.root);
    } else {
      this.loadList(this.root);
    }
    this.expandFolder(this.root);
  },

  onItemSelected: function(li) {
    $('site_site_root').value = this.getItemPath(li);
    $('site_site_root').fire('custom:change');
  },

  getRequestParams: function() {
    return $('site_form').serialize(true);
  }
});

SiteFtpTree.initForm = function(site_id) {
  $('site_server', 'site_login', 'site_password').each(function(input) {
    input.observe('change', function() {
      $('site_site_root').value = '';
      if($F('site_server') && $F('site_login') && $F('site_password')) {
        new SiteFtpTree()
      } else {
        $('ftp-tree').innerHTML = '';
      }
    });
  });

  if(site_id) {
    new SiteFtpTree(site_id);
  }
}

// PageFtpTree - for pages/new

var PageFtpTree = Class.create(FtpTree, {
  selectableClass: 'file',

  initialize: function($super, site_id, site_root) {
    $super(site_id);

    var tree = this;
    var parentNode = this.root;
    site_root.substr(1).split('/').each(function(name) {
      parentNode = tree.appendNode(parentNode, 'folder', name);
    });
    this.siteNode = parentNode;

    this.root.select('img.closed').each(function(img) {
      img.remove();
    });
    this.root.select('ul').each(function(ul) {
      ul.style.display = 'block';
    });

    this.loadList(this.siteNode);
  },

  onItemSelected: function(li) {
    $('page_path').value = this.getItemPathTo(li, this.siteNode);
    $('page_path').fire('custom:change');
  },

  getRequestParams: function() {
    return { site_id: this.site_id }
  }
});
