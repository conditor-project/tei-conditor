[![Build Status](https://travis-ci.org/conditor-project/tei-conditor.svg?branch=master)](https://travis-ci.org/conditor-project/tei-conditor)

# TEI-Conditor

This repository contains the XSL stylesheets for transforming XML files from different sources to a TEI file. These files are located in the folder src/source distributed in a folder for each sourced data (src/source/pubmed, src/source/hal, src/source/wos ...).

## Validation tests

This repository also contains xpath validation tests used by the Conditor processing chain. The validation tests will test each of the stylesheets in the data source directories (ex: src/source/pubmed/stylesheet.xsl) on the corresponding datasets in the test/dataset directory (ex: test/dataset/pubmed/file-123456.xml).

### Install
```sh
npm install
```

### Usage
```sh
npm test
```

Travis has been integrated and runs validation tests with each commit : https://travis-ci.org/conditor-project/tei-conditor