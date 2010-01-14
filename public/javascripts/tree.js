var FtpTree = Class.create({
  imageFolder: '/images/tree/',
  imageSuffix: '.gif',
  plusImage: 'plus.gif',
  minusImage: 'minus.gif',

  initialize: function() {
    var div = $('ftpTree');
    var form = $('site_form');
    var server = $F(form['site_server']);

    var ul = this.createBranch(
      div,
      '<li class="root"><span>' + server + '</span></li>'
    );
    this.loadFolder(ul.select('li').first());
  },

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
      if (li.className == 'folder') {
        var plusImg = $(document.createElement('img'));
        plusImg.className = 'plus';
        plusImg.src = tree.imageFolder + tree.plusImage;
        plusImg.onclick = tree.toggleFolder.bind(tree, li);

        aTag.onclick = tree.selectFolder.bind(tree, li);
        li.insertBefore(plusImg, aTag);
      }

      var iconImg = document.createElement('img');
      iconImg.src = tree.imageFolder + li.className + tree.imageSuffix;
      li.insertBefore(iconImg, aTag);
    });
  },

  selectFolder: function(li) {
    $('site_form')['site[site_root]'].value = this.getFolderPath(li);
    var selected = $('ftpTree').select('span.selected').first();
    if (selected) {
      selected.removeAttribute('class');
    }
    li.select('span').first().className = 'selected';
    this.toggleFolder(li);
  },

  toggleFolder: function(li) {
    var img = li.select('img').first();
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
    
    return false;
  },

  loadFolder: function(li) {
    this.createBranch(li, "<li class='load'><span>Loading...</span></li>");

    var tree = this;
    var params = $('site_form').serialize(true);
    params['site[site_root]'] = this.getFolderPath(li);
    new Ajax.Request('/sites/ls', {
      method: 'get',
      parameters: params,
      onSuccess: tree.parseResponse.bind(tree, li)
    });
  },

  parseResponse: function(li, response) {
    var error = response.getHeader('ftp_error');
    if (error) {
      $$('#ftpTree .error').innerHTML = error;
    }

    this.createBranch(li, response.responseText);
    if (li.select('li').size() == 0) {
      li.select('img.plus').each(function(plus) {
        plus.style.visibility = 'hidden';
      });
    }
  },

  getFolderPath: function(li) {
    var names = [];
    li.childElements().first().ancestors().each(function(folder) {
      if (folder.tagName == 'LI') {
        if (folder.className == 'root') {
          throw $break;
        } else {
          names.push(folder.select('span').first().innerHTML);
        }
      }
    });
    return '/' + names.reverse().join('/');
  }
});
