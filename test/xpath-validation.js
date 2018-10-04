'use strict';
/* eslint-env mocha */
/* eslint-disable no-unused-expressions */
const xpath = require('xpath');
const DOM = require('xmldom').DOMParser;
const path = require('path');
const Promise = require('bluebird');
const metadataXpaths = require('co-config/metadata-xpaths.json');
const Computron = require('computron');
Promise.promisifyAll(Computron.prototype);

describe('Xpath validation for Conditor load chaining', function () {
  let xmlDoc;

  before(function () {
    const transformer = new Computron();
    return transformer.loadStylesheetAsync(path.resolve('src/source/pubmed/Pubmed2Conditor_TEI1.xsl'))
      .then(() => transformer.applyAsync(path.join(__dirname, 'dataset/pubmed/pubmed-11748933.xml')))
      .then(xml => new DOM().parseFromString(xml))
      .then(doc => {
        xmlDoc = doc;
      })
      .catch(console.error);
  });

  metadataXpaths.map(metadataXpath => {
    it(`it should retriving ${metadataXpath.name}`, function () {
      const evaluator = xpath.parse(metadataXpath.path);
      const evaluatorOptions = {
        node: xmlDoc,
        namespaces: {
          'TEI': 'http://www.tei-c.org/ns/1.0',
          'xml': 'http://www.w3.org/XML/1998/namespace'
        },
        functions: {
          'lower-case': function (context, arg) {
            return context
              .contextNode
              .getAttribute('type')
              .toLowerCase();
          }
        }
      };
      evaluator.evaluate(evaluatorOptions);
    });
  });
});
