/* eslint-env mocha */

const path = require('path');
const { expect } = require('chai');
const Computron = require('computron');
const { getStylesheetFrom } = require('../index');

const stylesheetsPath = path.join(__dirname, '..', 'src', 'stylesheets');
const datasetPath = path.join(__dirname, 'dataset');

// TODO: do more advanced verifications on the TEI (not just checking the result length)

describe('Hal tests', () => {
  const halStylesheetsPath = path.join(stylesheetsPath, 'hal');
  const halDatasetPath = path.join(datasetPath, 'hal');
  const transformer = new Computron();

  before(async () => {
    const stylesheets = await getStylesheetFrom('hal');
    expect(stylesheets.length).to.equal(1);
    expect(stylesheets[0].path).to.equal(path.join(halStylesheetsPath, 'Hal2Condi.xsl'));
    transformer.loadStylesheet(stylesheets[0].path);
  });

  it('Apply Hal stylesheet on hal-01246266.xml', () => {
    const xml = transformer.apply(path.join(halDatasetPath, 'hal-01246266.xml'));
    expect(xml.length).to.be.greaterThan(0);
  });

  it('Apply Hal stylesheet on hal-01313778.xml', () => {
    const xml = transformer.apply(path.join(halDatasetPath, 'hal-01313778.xml'));
    expect(xml.length).to.be.greaterThan(0);
  });

  it('Apply Hal stylesheet on hal-01497129.xml', () => {
    const xml = transformer.apply(path.join(halDatasetPath, 'hal-01497129.xml'));
    expect(xml.length).to.be.greaterThan(0);
  });

  it('Apply Hal stylesheet on hal-01575728.xml', () => {
    const xml = transformer.apply(path.join(halDatasetPath, 'hal-01575728.xml'));
    expect(xml.length).to.be.greaterThan(0);
  });
});

describe('Pubmed tests', () => {
  const pubmedStylesheetsPath = path.join(stylesheetsPath, 'pubmed');
  const pubmedDatasetPath = path.join(datasetPath, 'pubmed');
  const transformer = new Computron();

  before(async () => {
    const stylesheets = await getStylesheetFrom('pubmed');
    expect(stylesheets.length).to.equal(1);
    expect(stylesheets[0].path).to.equal(path.join(pubmedStylesheetsPath, 'Pubmed2Condi.xsl'));
    transformer.loadStylesheet(stylesheets[0].path);
  });

  it('Apply Pubmed stylesheet on pubmed-11700088.xml', () => {
    const xml = transformer.apply(path.join(pubmedDatasetPath, 'pubmed-11700088.xml'));
    expect(xml.length).to.be.greaterThan(0);
  });

  it('Apply Pubmed stylesheet on pubmed-11748933.xml', () => {
    const xml = transformer.apply(path.join(pubmedDatasetPath, 'pubmed-11748933.xml'));
    expect(xml.length).to.be.greaterThan(0);
  });

  it('Apply Pubmed stylesheet on pubmed-29977837.xml', () => {
    const xml = transformer.apply(path.join(pubmedDatasetPath, 'pubmed-29977837.xml'));
    expect(xml.length).to.be.greaterThan(0);
  });
});

describe('Crossref tests', () => {
  const crossrefStylesheetsPath = path.join(stylesheetsPath, 'crossref');
  const crossrefDatasetPath = path.join(datasetPath, 'crossref');
  const transformer = new Computron();

  before(async () => {
    const stylesheets = await getStylesheetFrom('crossref');
    expect(stylesheets.length).to.equal(1);
    expect(stylesheets[0].path).to.equal(path.join(crossrefStylesheetsPath, 'Crossref2Conditor.xsl'));
    transformer.loadStylesheet(stylesheets[0].path);
  });

  it('Apply Crossref stylesheet on 10.1001_jama.2014.3.xml', () => {
    const xml = transformer.apply(path.join(crossrefDatasetPath, '10.1001_jama.2014.3.xml'));
    expect(xml.length).to.be.greaterThan(0);
  });

  it('Apply Crossref stylesheet on 10.1001_jamadermatol.2013.4662.xml', () => {
    const xml = transformer.apply(path.join(crossrefDatasetPath, '10.1001_jamadermatol.2013.4662.xml'));
    expect(xml.length).to.be.greaterThan(0);
  });

  it('Apply Crossref stylesheet on 10.1002_2012JB009978.xml', () => {
    const xml = transformer.apply(path.join(crossrefDatasetPath, '10.1002_2012JB009978.xml'));
    expect(xml.length).to.be.greaterThan(0);
  });
});

describe('Sudoc-theses tests', () => {
  const sudocStylesheetsPath = path.join(stylesheetsPath, 'sudoc-theses');
  const sudocDatasetPath = path.join(datasetPath, 'sudoc-theses');
  const transformer = new Computron();

  before(async () => {
    const stylesheets = await getStylesheetFrom('sudoc-theses');
    expect(stylesheets.length).to.equal(1);
    expect(stylesheets[0].path).to.equal(path.join(sudocStylesheetsPath, 'SudocThese2Conditor.xsl'));
    transformer.loadStylesheet(stylesheets[0].path);
  });

  it('Apply Sudoc-Theses stylesheet on 25651304X.xml', () => {
    const xml = transformer.apply(path.join(sudocDatasetPath, '25651304X.xml'));
    expect(xml.length).to.be.greaterThan(0);
  });

  it('Apply Sudoc-Theses stylesheet on 256505977.xml', () => {
    const xml = transformer.apply(path.join(sudocDatasetPath, '256505977.xml'));
    expect(xml.length).to.be.greaterThan(0);
  });

  it('Apply Sudoc-Theses stylesheet on 258916389.xml', () => {
    const xml = transformer.apply(path.join(sudocDatasetPath, '258916389.xml'));
    expect(xml.length).to.be.greaterThan(0);
  });
});
