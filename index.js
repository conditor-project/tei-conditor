const Promise = require('bluebird');
const fs = Promise.promisifyAll(require('fs'));
const path = require('path');

function getStylesheetFrom (target) {
  return walker(path.join(__dirname, 'src'))
    .then(directoryTree => get(directoryTree, 'stylesheets'))
    .then(source => {
      if (!target) return source;
      return get(source, target).filter(file => path.extname(file.name) === '.xsl');
    });
}

function getStylesheetFromSync (target) {
  const directoryTree = walkerSync(path.join(__dirname, 'src'));
  const source = getSync(directoryTree, 'stylesheets');
  if (!target) return source;
  return getSync(source, target).filter(file => path.extname(file.name) === '.xsl');
}

function get (directoryTree, target) {
  return Promise.filter(directoryTree, directory => directory.name === target)
    .then(directory => {
      if (directory.length === 0) return Promise.reject(new Error('no directory founded'));
      if (directory.length > 1) return Promise.reject(new Error('too many directories founded'));
      const objSource = directory.pop();
      if (objSource.children === undefined) return Promise.reject(new Error('directory empty'));
      return objSource.children;
    });
}

function getSync (directoryTree, target) {
  const directoryTreeFiltered = directoryTree.filter(directory => directory.name === target);
  if (directoryTreeFiltered.length === 0) throw new Error('no directory founded');
  if (directoryTreeFiltered.length > 1) throw new Error('too many directories founded');
  const objSource = directoryTreeFiltered.pop();
  if (!objSource.children === undefined) throw new Error('directory empty');
  return objSource.children;
}

function walker (directory) {
  return fs.readdirAsync(directory).map(content => {
    return fs.statAsync(path.join(directory, content)).then(stats => {
      const result = {
        name: content,
        path: path.join(directory, content),
        size: stats.size,
        type: 'unknown',
      };
      if (stats.isFile()) result.type = 'file';
      if (stats.isDirectory()) result.type = 'directory';
      return result;
    });
  }).map(content => {
    if (content.type === 'directory') {
      return walker(content.path).then(result => {
        content.children = result;
        return content;
      });
    }
    return content;
  });
}

function walkerSync (directory) {
  return fs.readdirSync(directory).map(content => {
    const stats = fs.statSync(path.join(directory, content));
    const result = {
      name: content,
      path: path.join(directory, content),
      size: stats.size,
      type: 'unknown',
    };
    if (stats.isFile()) result.type = 'file';
    if (stats.isDirectory()) result.type = 'directory';
    return result;
  }).map(content => {
    if (content.type === 'directory') {
      const children = walkerSync(content.path);
      content.children = children;
      return content;
    }
    return content;
  });
}

module.exports = { getStylesheetFrom, getStylesheetFromSync };
