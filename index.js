const Promise = require('bluebird');
const fs = Promise.promisifyAll(require('fs'));
const path = require('path');

const teiConditor = {};

teiConditor.getResource = function (source, type) {
  return this.walker(path.resolve('src'))
    .then(result => this.get(result, source))
    .then(result => this.get(result, type));
};

teiConditor.get = function (directoryTree, target) {
  return Promise.filter(directoryTree, directory => directory.name === target)
    .then(directory => {
      if (directory.length === 0) return Promise.reject(new Error('no source founded'));
      if (directory.length > 1) return Promise.reject(new Error('too many source founded'));
      const objSource = directory.pop();
      if (!objSource.hasOwnProperty('children')) return Promise.reject(new Error('directory empty'));
      return objSource.children;
    });
};

teiConditor.walker = function (directory) {
  return fs.readdirAsync(directory).map(content => {
    return fs.statAsync(path.join(directory, content))
      .then(stats => {
        const result = {
          name: content,
          path: path.join(directory, content),
          size: stats.size,
          type: 'unknown'
        };
        if (stats.isFile()) result.type = 'file';
        if (stats.isDirectory()) result.type = 'directory';
        return result;
      });
  }).map(content => {
    if (content.type === 'directory') {
      return this.walker(content.path).then(result => {
        content.children = result;
        return content;
      });
    }
    return content;
  });
};

// teiConditor.getResource('pubmed', 'xsl').then(result => {
//   console.dir(result, {depth: 8});
// });

module.exports = teiConditor;
