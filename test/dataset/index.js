const path = require('path');

module.exports = [
  {
    source: 'hal',
    name: 'hal-01246266.xml',
    path: path.join(__dirname, 'hal/hal-01246266.xml'),
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
    path: path.join(__dirname, 'hal/hal-01313778.xml'),
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
    path: path.join(__dirname, 'hal/hal-01575728.xml'),
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
    path: path.join(__dirname, 'pubmed/pubmed-11700088.xml'),
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
    path: path.join(__dirname, 'pubmed/pubmed-11748933.xml'),
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
    path: path.join(__dirname, 'pubmed/pubmed-29977837.xml'),
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