'use strict';
/* eslint-env mocha */
/* eslint-disable no-unused-expressions */
const { getStylesheetFromSync } = require('../index.js');
const xpath = require('xpath');
const { expect } = require('chai');
const DOM = require('xmldom').DOMParser;
const path = require('path');
const Promise = require('bluebird');
const metadataXpaths = require('co-config/metadata-xpaths.json');
const coFormatter = require('co-formatter');
const Computron = require('computron');
Promise.promisifyAll(Computron.prototype);

const datasets = [
  {
    source: 'hal',
    name: 'hal-01246266.xml',
    path: path.join(__dirname, 'dataset/hal/hal-01246266.xml'),
    xpathToTest: [
      'title',
      'first3AuthorNames',
      'authorNames',
      'first3AuthorNamesWithInitials',
      'authors',
      'issn',
      'xissn',
      'issue',
      'pageRange',
      'halId',
      'halAuthorId',
      'publicationDate',
      'abstract',
      'typeDocument',
      'isni'
    ]
  },
  {
    source: 'hal',
    name: 'hal-01313778.xml',
    path: path.join(__dirname, 'dataset/hal/hal-01313778.xml'),
    xpathToTest: [
      'title',
      'first3AuthorNames',
      'authorNames',
      'first3AuthorNamesWithInitials',
      'authors',
      'issn',
      'xissn',
      'doi',
      'pageRange',
      'volume',
      'halId',
      'halAuthorId',
      'publicationDate',
      'abstract',
      'typeDocument',
      'isni'
    ]
  },
  {
    source: 'hal',
    name: 'hal-01575728.xml',
    path: path.join(__dirname, 'dataset/hal/hal-01575728.xml'),
    xpathToTest: [
      'title',
      'first3AuthorNames',
      'authorNames',
      'first3AuthorNamesWithInitials',
      'authors',
      'halId',
      'idHal',
      'halAuthorId',
      'publicationDate',
      'abstract',
      'typeDocument',
      'isni'
    ]
  },
  {
    source: 'pubmed',
    name: 'pubmed-11700088.xml',
    path: path.join(__dirname, 'dataset/pubmed/pubmed-11700088.xml'),
    xpathToTest: [
      'title',
      'first3AuthorNames',
      'authorNames',
      'first3AuthorNamesWithInitials',
      'authors',
      'issn',
      'xissn',
      'pii',
      'doi',
      'pmid',
      'issue',
      'pageRange',
      'volume',
      'publicationDate',
      'abstract',
      'typeDocument'
    ]
  },
  {
    source: 'pubmed',
    name: 'pubmed-11748933.xml',
    path: path.join(__dirname, 'dataset/pubmed/pubmed-11748933.xml'),
    xpathToTest: [
      'title',
      'first3AuthorNames',
      'authorNames',
      'first3AuthorNamesWithInitials',
      'authors',
      'issn',
      'xissn',
      'pii',
      'doi',
      'pmid',
      'issue',
      'pageRange',
      'volume',
      'publicationDate',
      'abstract',
      'typeDocument'
    ]
  },
  {
    source: 'pubmed',
    name: 'pubmed-29977837.xml',
    path: path.join(__dirname, 'dataset/pubmed/pubmed-29977837.xml'),
    xpathToTest: [
      'title',
      'first3AuthorNames',
      'authorNames',
      'first3AuthorNamesWithInitials',
      'authors',
      'issn',
      'xissn',
      'pmc',
      'pii',
      'doi',
      'pmid',
      'issue',
      'pageRange',
      'volume',
      'publicationDate',
      'abstract',
      'typeDocument'
    ]
  }
];

describe('Xpath validation', function () {
  datasets.map(dataset => {
    const stylesheets = getStylesheetFromSync(dataset.source);
    stylesheets.map(stylesheet => {
      describe(`dataset ${dataset.name} transform with ${stylesheet.name}`, function () {
        metadataXpaths
          .filter(metadataXpath => dataset.xpathToTest.includes(metadataXpath.name))
          .map(metadataXpath => {
            it(`it should retrieving ${metadataXpath.name}`, function () {
              const transformer = new Computron();
              return transformer.loadStylesheetAsync(stylesheet.path)
                .then(() => transformer.applyAsync(dataset.path))
                .then(xml => new DOM().parseFromString(xml))
                .then(xmlDoc => {
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
            })
            .catch(error => {
              expect(error).to.be.an('error');
            });
        });
      });
    });
  });
});
