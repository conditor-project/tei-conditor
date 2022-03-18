'use strict';
/* eslint-env mocha */
/* eslint-disable no-unused-expressions */
const { getStylesheetFromSync } = require('../index.js');
const xpath = require('xpath');
const { expect } = require('chai');
const DOM = require('xmldom').DOMParser;
const Promise = require('bluebird');
const metadataXpaths = require('co-config/metadata-xpaths.json');
const coFormatter = require('co-formatter');
const Computron = require('computron');
Promise.promisifyAll(Computron.prototype);

const datasets = require('./dataset');

describe('Xpath validation', function () {
  datasets.map(dataset => {
    const stylesheets = getStylesheetFromSync(dataset.source);
    stylesheets.map(stylesheet => {
      describe(`dataset ${dataset.name} transform with ${stylesheet.name}`, function () {
        metadataXpaths
          .filter(metadataXpath => dataset.xpathToTest.includes(metadataXpath.name))
          .map(metadataXpath => {
            it(`it should retrieve ${metadataXpath.name}`, function () {
              const transformer = new Computron();
              return transformer.loadStylesheetAsync(stylesheet.path)
                .then(() => transformer.applyAsync(dataset.path, null))
                .then(xml => new DOM().parseFromString(xml))
                .then(xmlDoc => {
                  const evaluatorOptions = {
                    node: xmlDoc,
                    namespaces: coFormatter.namespaces,
                    functions: coFormatter.evalFunctions
                  };
                  const value = coFormatter.extract(metadataXpath, evaluatorOptions);
                  expect(value).to.not.be.empty;
                });
            });
          });

        it(`it should fail retrieving element with bad xpath`, function () {
          const badXpath = {
            name: 'nope',
            type: 'simpleString',
            path: '//TEI/path/to/nothing/'
          };
          const transformer = new Computron();
          return transformer.loadStylesheetAsync(stylesheet.path)
            .then(() => transformer.applyAsync(dataset.path))
            .then(xml => new DOM().parseFromString(xml))
            .then(xmlDoc => {
              const evaluator = xpath.parse(badXpath.path);
              const evaluatorOptions = {
                node: xmlDoc,
                namespaces: coFormatter.namespaces,
                functions: coFormatter.evalFunctions
              };
              evaluator.evaluate(evaluatorOptions);
            })
            .catch(error => {
              expect(error).to.be.an('error');
            });
        });
      });
    });
  });
});
