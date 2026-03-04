/**
 * @preserve
 *               ssSearch.js              
 * Authors: Martin Holmes and Joey Takeda.
 * mholmes@uvic.ca, joey.takeda@gmail.com.
 *       University of Victoria.          
 *
 * This file is part of the projectEndings staticSearch
 * project. 

 * Free to anyone for any purpose, but acknowledgement 
 * would be appreciated. The code is licensed under 
 * both MPL and BSD.
 *
 * WARNING:
 * This lib has "use strict" defined. You may
 * need to remove that if you are mixing this
 * code with non-strict JavaScript.
*/

"use strict";
/*              ssUtilities.js             */
/* Authors: Martin Holmes and Joey Takeda. */
/*        University of Victoria.          */

/** This file is part of the projectEndings staticSearch
  * project.
  *
  * Free to anyone for any purpose, but
  * acknowledgement would be appreciated.
  * The code is licensed under both MPL and BSD.
  */

/**
  * First some constant values for categorizing term types.
  * I would like to put these inside the class, but I can't
  * find an elegant way to do that.
  */
/**
  * @constant PHRASE, MUST_CONTAIN, MUST_NOT_CONTAIN, MAY_CONTAIN, WILDCARD
  * @type {Number}
  * @description Constants representing different types of search command. Note
  *              that WILDCARD is not currently used, but will be if the 
  *              implementation of wildcards is changed.
  */
  /** @type {!number} */
  const PHRASE               = 0;
  /** @type {!number} */
  const MUST_CONTAIN         = 1;
  /** @type {!number} */
  const MUST_NOT_CONTAIN     = 2;
  /** @type {!number} */
  const MAY_CONTAIN          = 3;
  /** @type {!number} */
  const WILDCARD             = 4;

/**@constant arrTermTypes
   * @type {Array}
   * @description array of PHRASE, MUST_CONTAIN, MUST_NOT_CONTAIN, MAY_CONTAIN,
   *              WILDCARD used so we can easily iterate through them.
   */
  const arrTermTypes = [PHRASE, MUST_CONTAIN, MUST_NOT_CONTAIN, MAY_CONTAIN, WILDCARD];

/**
  * @constant TO_GET, GETTING, GOT, FAILED
  * @type {Number}
  * @description Constants representing states of files that may be
  *              fetched.
  */
  /** @type {!number} */
  const TO_GET  = 0;
  /** @type {!number} */
  const GETTING = 1;
  /** @type {!number} */
  const GOT     = 2;
  /** @type {!number} */
  const FAILED  = 3;

/**
  * Components in the ss namespace that are used by default, but
  * which may easily be overridden by the project.
  */
/**
  * Our handy namespace
  * @namespace ss
  */
  var ss = {};

/**
  * @property ss.captions
  * @type {Map}
  * @description ss.captions is the an array of languages (default contains
  * only en and fr), each of which has some caption properties. Extend
  * by adding new languages or replace if necessary.
  */
  //English
  ss.captions = new Map();
  ss.captions.set('en', {});
  ss.captions.get('en').strLoading           = 'Loading...';
  ss.captions.get('en').strSearching         = 'Searching...';
  ss.captions.get('en').strDocumentsFound    = 'Documents found: ';
  ss.captions.get('en')[PHRASE]              = 'Exact phrase: ';
  ss.captions.get('en')[MUST_CONTAIN]        = 'Must contain: ';
  ss.captions.get('en')[MUST_NOT_CONTAIN]    = 'Must not contain: ';
  ss.captions.get('en')[MAY_CONTAIN]         = 'May contain: ';
  ss.captions.get('en')[WILDCARD]            = 'Wildcard term: ';
  ss.captions.get('en').strScore             = 'Score: ';
  ss.captions.get('en').strSearchTooBroad    = 'Your search is too broad. Include more letters in every term.';
  ss.captions.get('en').strDiscardedTerms    = 'Not searched (too common or too short): ';
  ss.captions.get('en').strShowMore          = 'Show more';
  ss.captions.get('en').strShowAll           = 'Show all';
  ss.captions.get('en').strTooManyResults    = 'Your search returned too many results. Include more filters or more search terms.';
  
  //French: thank you Claire Carlin.
  ss.captions.set('fr', {});
  ss.captions.get('fr').strLoading           = 'Chargement en cours...';
  ss.captions.get('fr').strSearching         = 'Recherche en cours...';
  ss.captions.get('fr').strDocumentsFound    = 'Documents localisés: ';
  ss.captions.get('fr')[PHRASE]              = 'Phrase exacte: ';
  ss.captions.get('fr')[MUST_CONTAIN]        = 'Doit contenir: ';
  ss.captions.get('fr')[MUST_NOT_CONTAIN]    = 'Ne doit pas contenir: ';
  ss.captions.get('fr')[MAY_CONTAIN]         = 'Peut contenir: ';
  ss.captions.get('fr')[WILDCARD]            = 'Caractère générique: ';
  ss.captions.get('fr').strScore             = 'Score: ';
  ss.captions.get('fr').strSearchTooBroad    = 'Votre recherche est trop large. Inclure plus de lettres dans chaque terme.';
  ss.captions.get('fr').strDiscardedTerms    = 'Recherche inaboutie (termes trop fréquents ou trop brefs): ';
  ss.captions.get('fr').strShowMore          = 'Montrez plus';
  ss.captions.get('fr').strShowAll           = 'Montrez tout';
  ss.captions.get('fr').strTooManyResults    = 'Votre recherche a obtenu trop de résultats. Il faut inclure plus de filtres ou plus de termes de recherche.';
  
  //German: thank you @babslgam and @martinantonmueller
  ss.captions.set('de', {});
  ss.captions.get('de').strLoading           = 'lädt…';
  ss.captions.get('de').strSearching         = 'sucht…';
  ss.captions.get('de').strDocumentsFound    = 'Treffer: ';
  ss.captions.get('de')[PHRASE]              = 'Exakte Formulierung: ';
  ss.captions.get('de')[MUST_CONTAIN]        = 'Muss enthalten: ';
  ss.captions.get('de')[MUST_NOT_CONTAIN]    = 'Darf nicht enthalten: ';
  ss.captions.get('de')[MAY_CONTAIN]         = 'Kann enthalten: ';
  ss.captions.get('de')[WILDCARD]            = 'Platzhalter: ';
  ss.captions.get('de').strScore             = 'Rating: ';
  ss.captions.get('de').strSearchTooBroad    = 'Die Suche ergibt zu viele Treffer. Bitte die Zeichenzahl im Wort erhöhen.';
  ss.captions.get('de').strDiscardedTerms    = 'Nicht gesucht (zu kurz oder zu allgemein): ';
  ss.captions.get('de').strShowMore          = 'Mehr';
  ss.captions.get('de').strShowAll           = 'Zeige alles';
  ss.captions.get('de').strTooManyResults    = 'Die Suche ergibt zu viele Treffer. Durch Filterung oder Suchbegriffe einschränken.';

/**
  * @property ss.stopwords
  * @type {!Array}
  * @description a simple array of stopwords. Extend
  * by adding new items or replace if necessary. If a local
  * stopwords.json file exists, that will be loaded and overwrite
  * this set.
  */
  ss.stopwords = new Array('i', 'me', 'my', 'myself', 'we', 'our', 'ours', 'ourselves', 'you', 'your', 'yours', 'yourself', 'yourselves', 'he', 'him', 'his', 'himself', 'she', 'her', 'hers', 'herself', 'it', 'its', 'itself', 'they', 'them', 'their', 'theirs', 'themselves', 'what', 'which', 'who', 'whom', 'this', 'that', 'these', 'those', 'am', 'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'having', 'do', 'does', 'did', 'doing', 'a', 'an', 'the', 'and', 'but', 'if', 'or', 'because', 'as', 'until', 'while', 'of', 'at', 'by', 'for', 'with', 'about', 'against', 'between', 'into', 'through', 'during', 'before', 'after', 'above', 'below', 'to', 'from', 'up', 'down', 'in', 'out', 'on', 'off', 'over', 'under', 'again', 'further', 'then', 'once', 'here', 'there', 'when', 'where', 'why', 'how', 'all', 'any', 'both', 'each', 'few', 'more', 'most', 'other', 'some', 'such', 'no', 'nor', 'not', 'only', 'own', 'same', 'so', 'than', 'too', 'very', 's', 't', 'can', 'will', 'just', 'don', 'should', 'now');
  
  
/**
  * @function ss.debounce
  * @description This is a generic debounce function borrowed from here:
  *           https://levelup.gitconnected.com/debounce-in-javascript-improve-your-applications-performance-5b01855e086
  *           which borrowed it from here:
  *           https://davidwalsh.name/javascript-debounce-function
  *           Returns a function, that, as long as it continues to be invoked, will not
  *           be triggered. The function will be called after it stops being called for
  *           `wait` milliseconds.
  * @param {!function} func The function to be called after debouncing.
  * @param {!Number} wait The number of milliseconds to wait before running the function.
  */
  ss.debounce = (func, wait) => {
    let timeout;

    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };

      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  };
/*             StaticSearch.js             */
/* Authors: Martin Holmes and Joey Takeda. */
/*        University of Victoria.          */

/** This file is part of the projectEndings staticSearch
  * project.
  *
  * Free to anyone for any purpose, but
  * acknowledgement would be appreciated.
  * The code is licensed under both MPL and BSD.
  */

/** @class StaticSearch
  * @description This is the class that handles parsing the user's
  * input, through typed queries in the search box and selections in
  * search filters.
  *
  * It expects to find the following HTML items in
  * the HTML of the search page which includes it
  * (expressed as CSS selectors):
  *
  * input#ssQuery[type='text']   (the main search box)
  * button#ssDoSearch            (button for invoking search)
  * div#ssSearching              (div containing message to show search is under way)
  * div#ssResults                (div in which to output the results)
  * input[type='checkbox'].staticSearch_desc  (optional; checkbox lists for filtering based on text labels)
  * input[type='text'].staticSearch_date      (optional; textboxes for date filters)
  * input[type='number'].staticSearch_num      (optional; inputs for numerical filters)
  * input[type='checkbox'].staticSearch_bool  (optional: checkboxes for boolean filters)
  * input[type='text'].staticSearch_text  (NOT YET IMPLEMENTED: type-in search filter boxes)
  *
  * The first is mandatory, although the user is
  * not required to use it; they may choose simply
  * to retrieve filtered lists of documents.
  * The second is mandatory, although the user may also invoke
  * search by pressing return while the text box has focus.
  * The third is mandatory, because there must be somewhere to
  * show the results of a search.
  * The rest are optional, but if present,
  * they will be incorporated.
  */
class StaticSearch{
/** 
  * constructor
  * @description The constructor has no paramaters since it
  *              reads everything it requires from the host
  *              HTML page. 
  */
  constructor(){
    try {
    
      //Captions are done first, since we need one for the splash screen.
      this.captions = ss.captions; //Default; override this if you wish by setting the property after instantiation.
      this.captionLang  = document.getElementsByTagName('html')[0].getAttribute('lang') || 'en'; //Document language.
      if (this.captions.has(this.captionLang)){
        this.captionSet   = this.captions.get(this.captionLang); //Pointer to the caption object we're going to use.
      }
      else{
        this.captionSet   = this.captions.get('en');
      }
      
      this.splashMessage = document.getElementById('ssSplashMessage');
      if (this.splashMessage !== null){
        //Set the caption in the splash screen.
        this.splashMessage.innerText = this.captionSet.strLoading;
        
        //Now we "show" the splash screen.
        document.body.classList.add('ssLoading');
      }

      
      this.ssForm = document.querySelector('#ssForm');
      if (!this.ssForm){
        throw new Error('Failed to find search form. Search functionality will probably break.');
      }
      //Directory where all of the JSONs are stored
      this.jsonDirectory = this.ssForm.getAttribute('data-ssfolder') || 'staticSearch'; //Where to find all the stuff.
      this.jsonDirectory += '/';

      //Headers used for all AJAX fetch requests.
      this.fetchHeaders = {
              credentials: 'same-origin',
              cache: 'default',
              headers: {'Accept': 'application/json'},
              method: 'GET',
              redirect: 'follow',
              referrer: 'no-referrer'
        };

      //Essential query text box.
      this.queryBox =
           document.querySelector("input#ssQuery[type='text']");
      if (!this.queryBox){
        throw new Error('Failed to find text input box with id "ssQuery". Cannot provide search functionality.');
      }
      else{
        this.queryBox.focus();
      }
      //Essential search button.
      this.searchButton =
           document.querySelector("button#ssDoSearch");
      if (!this.searchButton){
       throw new Error('Failed to find search button. Cannot provide search functionality.');
      }
      else{
        this.searchButton.addEventListener('click', function(){this.doSearch(); return false;}.bind(this));
      }

      //Optional second search button
      this.searchButton2 =
           document.querySelector("button#ssDoSearch2");
      if (this.searchButton2){
        this.searchButton2.addEventListener('click', function(){this.doSearch(); return false;}.bind(this));
      }

      //Clear button will be there if there are filter controls.
      this.clearButton = document.querySelector("button#ssClear");
      if (this.clearButton){
        this.clearButton.addEventListener('click', function(){this.clearSearchForm(); return false;}.bind(this));
      }

      //Essential "searching under way" message div.
      this.searchingDiv =
           document.querySelector("div#ssSearching");
      if (!this.searchingDiv){
       throw new Error('Failed to find div with id "ssSearching". Cannot provide search functionality.');
      }

      //Essential results div.
      this.resultsDiv =
           document.querySelector("div#ssResults");
      if (!this.resultsDiv){
       throw new Error('Failed to find div with id "ssResults". Cannot provide search functionality.');
      }

      // Search in fieldset name for the URL
      this.searchInFieldset = document.querySelector('.ssSearchInFilters > fieldset');
      if (this.searchInFieldset){
        this.searchInFieldsetName = this.searchInFieldset.title;
      }

      //Optional search filters:
      //Search in filters
      this.searchInFilterCheckboxes =
           Array.from(document.querySelectorAll("input[type='checkbox'].staticSearch_searchIn"));

      //Description label filters
      this.descFilterCheckboxes =
           Array.from(document.querySelectorAll("input[type='checkbox'].staticSearch_desc"));
      //Date filters
      this.dateFilterTextboxes =
           Array.from(document.querySelectorAll("input[type='text'].staticSearch_date"));
      //Number filters
      this.numFilterInputs =
           Array.from(document.querySelectorAll("input[type='number'].staticSearch_num"));
      //Boolean filters
      this.boolFilterSelects =
           Array.from(document.querySelectorAll("select.staticSearch_bool"));


      //Feature filters will eventually have checkboxes, but they don't yet.
      this.featFilterCheckboxes = [];
      //However they do have inputs.
      this.featFilterInputs = 
            Array.from(document.querySelectorAll("input[type='text'].staticSearch_feat"));
      //And we set them all to disabled initially
      for (let ffi of this.featFilterInputs){
        ffi.disabled = true;
      }
      //We need an array in which to store any possible feature filters that 
      //need to be created based on settings in the URL query string.
      this.mapFeatFilters = new Map();

      //Now we have some properties that will may be used later if required.
      this.paginationBtnDiv = null;
      this.showMoreBtn      = null;
      this.showAllBtn       = null;
      /** @type {!Array<string>} */
      this.normalizedQuery  = [];
      
      //An object which will be filled with a complete list of all the
      //individual stems indexed for the site. Data retrieved later by
      //AJAX.
      this.stems = null;

      //A string which will contain a chain of all the distinct word-forms 
      //on the site, used to support wildcard searches.
      this.wordString = '';

      //A Map object that will be populated with filter data retrieved by AJAX.
      this.mapFilterData = new Map();

      //A Map object that will track the retrieval of search filter data and
      //other JSON files we need to get. Note: one of the files is txt, not JSON.
      this.mapJsonRetrieved = new Map();

      //A Map object which will be repopulated on every search initiation,
      //containing the set of active document filters to apply to the search.
      this.mapActiveFilters = new Map();

      //An XSet object which will contain a list of docUris which pass the
      //test of the currently-configured set of filters. This is recreated
      //for every search.
      this.docsMatchingFilters = new XSet();

      //An XSet object that will contain a list of active contexts
      this.activeContexts = new XSet();

      //Any / all selector for combining filters. TODO. MAY NOT BE USED.
      this.matchAllFilters = false;

      //Nested convenience function for getting int values from form attributes.
      this.getConfigInt = function getConfigInt(ident, defaultVal){
        let i = parseInt(this.ssForm.getAttribute('data-' + ident.toLowerCase()), 10);
        return (isNaN(i))? defaultVal : i;
      }

      //Nested convenience function for getting string values from form attributes.
      this.getConfigStr = function getConfigStr(ident, defaultVal){
        let str = this.ssForm.getAttribute('data-' + ident.toLowerCase());
        return (str != null)? str : defaultVal;
      }

      //Nested convenience function for getting bool values from form attributes.
      //This allows latitude in how bools are specified.
      this.getConfigBool = function getConfigBool(ident, defaultVal){
        let b = this.ssForm.getAttribute('data-' + ident.toLowerCase());
        return (/^\s*(y|Y|yes|true|True|1)\s*$/.test(b))? true : (/^\s*(n|N|no|false|False|0)\s*$/.test(b))? false: defaultVal;
      }

      //Configuration for phrasal searches if found. Default true.
      this.allowPhrasal = this.getConfigBool('allowphrasal', true);

      //Configuration for use of wildcards. Default false.
      this.allowWildcards = this.getConfigBool('allowwildcards', false);

      //String for leading and trailing truncations of KWICs.
      this.kwicTruncateString = this.getConfigStr('kwictruncatestring', '...');

      //Regex for removing truncate strings
      let escTrunc = this.kwicTruncateString.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      this.reKwicTruncateStr = new RegExp('(^' + escTrunc + ')|(' + escTrunc + '$)', 'g');

      //Limit to the weight of JSON that will be downloaded for a 
      //single wildcard term. NOT CURRENTLY USED. Default 1MB.
      this.downloadLimit = this.getConfigInt('downloadLimit', 1000000);

      //Limit the number of results that can be rendered for any given search
      this.resultsLimit = this.getConfigInt('resultslimit', 2000);

      //Configuration for minimum length of a term to be searched.
      this.minWordLength = this.getConfigInt('minwordlength', 3);

      //A flag for easier debugging.
      this.debug = false;

      //Configuration of a specific version string to avoid JSON caching.
      this.versionString = this.ssForm.getAttribute('data-versionstring');

      //Associative array for storing retrieved JSON search string data.
      //Any retrieved data stored in here is retained between searches
      //to avoid having to retrieve it twice.
      this.index = {};

      //Porter2 stemmer object.
      this.stemmer = new SSStemmer();

      //Array of terms parsed out of search string. This is emptied
      //at the beginning of every new search.
      this.terms = new Array();

      //An arbitrary limit on the number of stems we will search for in 
      //any given search. TODO: May need to provide an error message 
      //for this. Default 50.
      this.termLimit = this.getConfigInt('termLimit', 50);

      //An array to collect terms which are to be ignored in the search
      //because they are too short or are in the stopword list.
      this.discardedTerms = [];

      //A pattern to check the search string to ensure that it's not going
      //to retrieve a million words. 
      this.termPattern = new RegExp('^([\\*\\?\\[\\]]*[^\\*\\?\\[\\]]){' + this.minWordLength + ',}[\\*\\?\\[\\]]*$');

      //Characters to be discarded in all but phrasal
      this.charsToDiscardPattern = /[\.,!;:@#$%”“\^&]/g;
      if (!this.allowWildcards){
          this.charsToDiscardPattern = /[\.,!;:@#$%\^&*?\[\]]/g;
         
      };

      //Default set of stopwords
      /** @type {!Array} this.stopwords */
      this.stopwords = ss.stopwords; //temporary default.

      //The collection of JSON filter files that we need to retrieve.
      this.jsonToRetrieve = [];
      this.jsonToRetrieve.push({id: 'ssStopwords', path: this.jsonDirectory + 'ssStopwords' + this.versionString + '.json'});
      this.jsonToRetrieve.push({id: 'ssTitles', path: this.jsonDirectory + 'ssTitles' + this.versionString + '.json'});
      this.jsonToRetrieve.push({id: 'ssWordString', path: this.jsonDirectory + 'ssWordString' + this.versionString + '.txt'});
      for (var f of document.querySelectorAll('fieldset.ssFieldset[id], fieldset.ssFieldset select[id]')){
        this.jsonToRetrieve.push({id: f.id, path: this.jsonDirectory + 'filters/' + f.id + this.versionString + '.json'});
      }
      //Flag to be set when all JSON is retrieved, to save laborious checking on
      //every search.
      this.allJsonRetrieved = false;

      // Flag for telling whether we are currently doing a search;
      // which starts off false, but may be set to true later on
      this.isSearching = false;


      //Boolean: should this instance report the details of its search
      //in human-readable form?
      this.showSearchReport = false;

      //How many results should be shown per page? Default to 0,
      //which means all
      this.resultsPerPage = this.getConfigInt('resultsPerPage', 0);

      // If we're paginating the results, we may need some
      // other properties
      if (this.resultsPerPage > 0){
        // The selector for the result items (we define it here since it's conceivable that the
        // results may be structured differently)
        this.resultItemsSelector = `:scope > ul > li`;
        // Current page is 0
        this.currPage = 0;
        // And some null variables that are used iff the results are paginated
        this.currItem = null;
        this.resultItems = null;
      }

      //How many keyword in context strings should be included
      //in search results? Default 10.
      this.maxKwicsToShow = this.getConfigInt('maxKwicsToShow', 10);

      //Result handling object
      this.resultSet = new SSResultSet(this.maxKwicsToShow, this.reKwicTruncateStr);

      //This allows the user to navigate through searches using the back and
      //forward buttons; to avoid repeatedly pushing state when this happens,
      //we pass popping = true.
      window.onpopstate = function(){this.parseUrlQueryString(true)}.bind(this);

      //We may need to turn off the browser history manipulation to do
      //automated tests, so make this switchable.
      this.storeSearchesInBrowserHistory = true;

      //Now we can start trickle-downloading the various JSON files.
      this.getJson(0);

      //We add a hook which external code can call to be notified when a
      //search has completed.
      this.searchFinishedHook = function(num){};

      //We add another function which can be overridden by end-users if
      //for example they need the results div to be scrolled while taking
      //account of a fixed page header or something similar.
      this.scrollToResults = function(){this.resultsDiv.scrollIntoView({behavior: 'smooth', block: 'start'});};

      //We add a method which can be overridden by end users to do any 
      //special handling for input strings (such as removing some diacritics
      //but not others).
      this.preProcessSearchString = function(strSearch){return strSearch;};

      //Now we're instantiated, check to see if there's a query
      //string that should initiate a search.
      this.parseUrlQueryString();

      //Emit an event to notify that the object is instantiated.
      window.dispatchEvent(new CustomEvent('ssInstantiated'));
    }
    catch(e){
      console.log('ERROR: ' + e.message);
    }
  }

/** @function staticSearch~jsonRetrieved
  * @description this function is called whenever a resource is retrieved
  *              by the trickle-download process initiated on startup. It
  *              stores the data in the right place, and sets a flag to say
  *              that the data has been retrieved (or was not available).
  *
  * @param {*} json
  *             the JSON retrieved by the AJAX request (not always
  *             actually JSON).
  * @param {!string} path the path from which it was retrieved.
  * @suppress {missingProperties} The compiler doesn't know about properties 
  * of the json param, which could be one of several types of thing.
  * 
  */
  jsonRetrieved(json, path){
    if (path.match(/ssStopwords.*json$/)){
      this.stopwords = json.words;
      this.mapJsonRetrieved.set('ssStopwords', GOT);
      return;
    }
    if (path.match(/ssWordString.*txt$/)){
      this.wordString = json; //Not really JSON in this one case.
      this.mapJsonRetrieved.set('ssWordString', GOT);
      return;
    }
    if (path.match(/ssTitles.*json$/)){
      /** @suppress {checkTypes} Compiler is ignorant of the type of json. */
      this.resultSet.titles = new Map(Object.entries(json));
      this.mapJsonRetrieved.set('ssTitles', GOT);
      return;
    }
    if (path.match(/\/filters\//)){
      this.mapFilterData.set(json.filterName, json);
      this.mapJsonRetrieved.set(json.filterId, GOT);
      if (path.match(/ssFeat/)){
        this.setupFeatFilter(json.filterId, json.filterName);
      }
      return;
    }
  }

/** @function staticSearch~getJson
  * @description this function trickle-downloads a series of resource files
  *              which the object has determined it may need, getting
  *              them one at a time to avoid saturating the connection;
  *              while this is happening, a live search may be initiated
  *              which needs to get a lot of resources quickly.
  *
  * @param {number} jsonIndex the index of the item in the array of items
  *               that need to be retrieved.
  */
  async getJson(jsonIndex){
    if (jsonIndex < this.jsonToRetrieve.length){
      try{
        if (this.mapJsonRetrieved.get(this.jsonToRetrieve[jsonIndex].id) != GOT){
          this.mapJsonRetrieved.set(this.jsonToRetrieve[jsonIndex].id, GETTING);
          let fch = await fetch(this.jsonToRetrieve[jsonIndex].path);
          let json = /.*\.txt$/.test(this.jsonToRetrieve[jsonIndex].path)? await fch.text() : await fch.json();
          this.jsonRetrieved(json, this.jsonToRetrieve[jsonIndex].path);
        }
        else{
          return this.getJson(jsonIndex + 1);
        }
      }
      catch(e){
        console.log('ERROR: failed to retrieve resource ' + this.jsonToRetrieve[jsonIndex].path + ': ' + e.message);
        this.mapJsonRetrieved.set(this.jsonToRetrieve[jsonIndex].id, FAILED);
      }
      return this.getJson(jsonIndex + 1);
    }
    else{
      this.allJsonRetrieved = true;
      document.body.classList.remove('ssLoading');
      //Emit an event to notify that all Json has been retrieved.
      window.dispatchEvent(new CustomEvent('ssJsonRetrieved'));
    }
  }

/** @function StaticSearch~setupFeatFilter
  * @description this function runs when the json for a specific
  *              feature filter is retrieved; it enables the 
  *              control and assigns functionality events to it.
  * @param {!string} filterId the id of the filter to set up.
  * @param {!string} filterName the string name of the filter.
  * @param {!number} minNameLength the minimum length for the string
  *               a user types into the control at which a search 
  *               of the filter values will be initiated.
  * @return {boolean} true if a filter is found and set up, else false.
  */
  setupFeatFilter(filterId, filterName, minNameLength){
    let featFilter = document.getElementById(filterId);
    if (featFilter !== null){
      try{
        //Now we set up the control as a typeahead.
        let filterData = this.mapFilterData.get(filterName);
        this.mapFeatFilters.set(filterName, new SSTypeAhead(featFilter, filterData, filterName, minNameLength));
        //Re-enable it.
        let inp = featFilter.querySelector('input');
        inp.disabled = false;
      }
      catch(e){
        console.log('ERROR: failed to set up feature filter ' + filterId + ': ' + e);
        return false;
      }
    }
    else{
      console.log('ERROR: failed to find feature filter ' + filterId);
      return false;
    }
  }

/** @function StaticSearch~parseUrlQueryString
  * @description this function is run after the class is instantiated
  *              to check whether there is a search string in the
  *              browser URL. If so, it parses it out and runs the
  *              query.
  *
  * @param {!boolean} popping specifies whether this parse has been triggered
  *                  by window.onpopstate (meaning the user is moving through
  *                  the browser history)
  * @return {boolean} true if a search is initiated otherwise false.
  */
  async parseUrlQueryString(popping = false){
    let searchParams = new URLSearchParams(decodeURI(document.location.search));
    //Do we need to do a search?
    let searchToDo = false; //default

    //Keep an array of all the elements we configure so we can traverse
    //the hierarchy and open any closed details elements above them.
    let changedControls = [];

    if (searchParams.has('q')){
      let currQ = searchParams.get('q').trim();
      if (currQ !== ''){
        this.queryBox.value = searchParams.get('q');
        searchToDo = true;
        changedControls.push(this.queryBox);
      }
    }

    for (let cbx of this.searchInFilterCheckboxes){
      if ((searchParams.has(this.searchInFieldsetName)) && (searchParams.getAll(this.searchInFieldsetName).indexOf(cbx.value) > -1)){
          cbx.checked = true;
          searchToDo = true;
          changedControls.push(cbx);
      } else {
        cbx.checked = false;
      }
    }

    for (let cbx of this.descFilterCheckboxes){
      let key = cbx.getAttribute('title');
      if ((searchParams.has(key)) && (searchParams.getAll(key).indexOf(cbx.value) > -1)){
          cbx.checked = true;
          searchToDo = true;
          changedControls.push(cbx);
      }
      else{
        cbx.checked = false;
      }
    }
    //Have to do something similar but way more clever for the ssFeat filters.
    //For each feature filter
    for (let inp of this.featFilterInputs){
    //check whether it's mentioned in the search params
      let key = inp.getAttribute('title');
      let filterId = inp.parentNode.id;
      if (searchParams.has(key)){
        searchToDo = true;
        changedControls.push(inp);
    //if so, check whether its typeahead control has been set up yet.
        if (!this.mapFeatFilters.has(key)){
    //If not, await its JSON retrieval, and set it up.
          let fch = await fetch(this.jsonDirectory + 'filters/' + filterId + this.versionString + '.json');
          let json = await fch.json();
          this.mapFilterData.set(json.filterName, json);
          this.setupFeatFilter(json.filterId, json.filterName, json.minNameLength);
        }
    //Then set its checkboxes appropriately.
        this.mapFeatFilters.get(key).setCheckboxes(searchParams.getAll(key));
      }
    }
    for (let txt of this.dateFilterTextboxes){
      let key = txt.getAttribute('title') + txt.id.replace(/^.+((_from)|(_to))$/, '$1');
      if ((searchParams.has(key)) && (searchParams.get(key).length > 3)){
        txt.value = searchParams.get(key);
        searchToDo = true;
        changedControls.push(txt);
      }
      else{
        txt.value = '';
      }
    }
    for (let num of this.numFilterInputs){
      let key = num.getAttribute('title') + num.id.replace(/^.+((_from)|(_to))$/, '$1');
      if ((searchParams.has(key)) && (searchParams.get(key).length > 0)){
        num.value = searchParams.get(key);
        searchToDo = true;
        changedControls.push(num);
      }
      else{
        num.value = '';
      }
    }
    for (let sel of this.boolFilterSelects){
      let key = sel.getAttribute('title');
      let val = (searchParams.has(key))? searchParams.get(key) : '';
      switch (val){
        case 'true':
          sel.selectedIndex = 1;
          searchToDo = true;
          changedControls.push(sel);
          break;
        case 'false':
          sel.selectedIndex = 2;
          searchToDo = true;
          changedControls.push(sel);
          break;
        default:
          sel.selectedIndex = 0;
      }
    }

    if (searchToDo === true){
      //Open any ancestor details elements.
      this.openAncestorElements(changedControls);

      this.doSearch(popping);
      return true;
    }
    else{
      return false;
    }
  }

/** @function StaticSearch~openAncestorElements
 * @param {Array} startingElements The array of elements from which
 *                to search up the tree for ancestors which need to
 *                be opened. For each element, any ancestor details
 *                element is opened so that the starting control
 *                is not hidden.
 * @return {boolean} true if any change is made, otherwise false.
 */
  openAncestorElements(startingElements){
    let retVal = false;
    startingElements.forEach(function(ctrl){
      let d = ctrl.closest('details:not([open])');
      while (d !== null){
        d.open = true;
        retVal = true;
        d = d.closest('details:not([open])');
      }
    });
    return retVal;
  }

/** @function StaticSearch~doSearch
  * @description this function initiates the search process,
  *              taking it as far as creating the promises
  *              for retrieval of JSON files. After that, the
  *              resolution of the promises carries the process
  *              on.
  * @param {!boolean} popping specifies whether this parse has been triggered
  *                  by window.onpopstate (meaning the user is moving through
  *                  the browser history)
  * @return {boolean} true if a search is initiated otherwise false.
  * 
  */
  doSearch(popping = false){
  //We start by intercepting any situation in which we may need the
  //ssWordString resource, but we don't yet have it.
    if (this.allowWildcards){
      if (/[\[\]?*]/.test(this.queryBox.value)){
        var self = this;
        if (this.mapJsonRetrieved.get('ssWordString') != GOT){
          let promise = fetch(self.jsonDirectory + 'ssWordString' + self.versionString + '.txt', self.fetchHeaders)
            .then(function(response) {
              return response.text();
            }.bind(this))
            .then(function(text) {
              self.wordString = text;
              self.mapJsonRetrieved.set('ssWordString', GOT);
              self.doSearch();
            }.bind(this))
            .catch(function(e){
              console.log('Error attempting to retrieve word list: ' + e);
            }.bind(this));
          return false;
        }
      }
    }
    //Emit an event to notify that the object is instantiated.
    window.dispatchEvent(new CustomEvent('ssSearchStarting'));
    // Now initialize that we're searching
    this.isSearching = true;
     //And now setup the timeout
    this.setupSearchingDiv();
    this.docsMatchingFilters.filtersActive = false; //initialize.
    let result = false; //default.
    this.discardedTerms = []; //Clear discarded terms.
    if (this.parseSearchQuery()){
      if (this.writeSearchReport()){
        this.populateIndexes();
        if (!popping){
          this.setQueryString();
        }
        result = true;
      }
      else{
        this.isSearching = false;
      }
    }
    else{
      this.isSearching = false;
    }
    this.scrollToResults();
    return result;
  }

  /** @function StaticSearch~setupSearchingDiv
   * @description this function sets up the "Searching..." popup message,
   * by adding a class to the document body that makes the ssSearching div
   * appear; it then sets polls to see whether StaticSearch.isSearching has been
   * set back to false and, if so, removes the class
   *
   */
  setupSearchingDiv() {
    let self = this;
    // Just check before initiating that it
    // hasn't already been initiated
    if (!document.body.classList.contains('ssSearching')){
      // Add the searching class to the body;
      document.body.classList.add('ssSearching');
      // And now create the timeout function that calls itself
      // to see whether a searching is still ongoing
      const timeout = function(){
        if (!self.isSearching){
          document.body.classList.remove('ssSearching');
          return;
        }
        window.setTimeout(timeout, 100);
      }
      timeout();
    }
  }





  /** @function StaticSearch~setQueryString
  * @description this function is run once a search is initiated,
  * and it takes the search parameters and creates a browser URL
  * search string, then pushes this into the History object so that
  * all searches are bookmarkable.
  *
  * @return {boolean} true if successful, otherwise false.
  */
  setQueryString(){
    try{
      if (this.storeSearchesInBrowserHistory == true){
        let url = window.location.href.split(/[?#]/)[0];
        let search = [];
        let q = this.queryBox.value.replace(/\s+/, ' ').replace(/(^\s+)|(\s+$)/g, '');
        if (q.length > 0){
          search.push('q=' + encodeURIComponent(q));
        }

        //Search in filter handling
        for (let cbx of this.searchInFilterCheckboxes){
          if (cbx.checked){
            search.push(this.searchInFieldsetName + "=" + cbx.value);
          }
        }

        for (let cbx of this.descFilterCheckboxes){
          if (cbx.checked){
            search.push(cbx.title + '=' + cbx.value);
          }
        }
        //Feature filter checkboxes need to be discovered first, since 
        //they're mutable.
        this.featFilterCheckboxes = 
          Array.from(document.querySelectorAll("input[type='checkbox'].staticSearch_feat"));
        for (let cbx of this.featFilterCheckboxes){
          if (cbx.checked){
            search.push(cbx.title + '=' + cbx.value);
          }
        }
        for (let txt of this.dateFilterTextboxes){
          if (txt.value.match(/\d\d\d\d(-\d\d(-\d\d)?)?/)){
            let key = txt.getAttribute('title') + txt.id.replace(/^.+((_from)|(_to))$/, '$1');
            search.push(key + '=' + txt.value);
          }
        }
        for (let num of this.numFilterInputs){
          if (num.value.match(/[\d\-\.]+/)){
            let key = num.getAttribute('title') + num.id.replace(/^.+((_from)|(_to))$/, '$1');
            search.push(key + '=' + num.value);
          }
        }
        for (let sel of this.boolFilterSelects){
          if (sel.selectedIndex > 0){
            search.push(sel.getAttribute('title') + '=' + ((sel.selectedIndex == 1)? 'true' : 'false'));
          }
        }

        if (search.length > 0){
          url += '?' + encodeURI(search.join('&'));
          history.pushState({time: Date.now()}, '', url);
        }
        else{
//If there are no search parameters, clear the URL.
          history.pushState({time: Date.now()}, '', url);
        }
      }
      /*else{
        console.log('Not storing search in browser history.');
      }*/
      return true;
    }
    catch(e){
      console.log('ERROR: failed to push search into browser history: ' + e.message);
    }
  }

/** @function StaticSearch~parseSearchQuery
  * @description this retrieves the content of the text
  * search box and parses it into an array of term items
  * ready for analysis against retrieved results. Even if
  * no search terms are found, it returns true so that filter-only
  * searches may proceed.
  *
  * @return {boolean} true if no errors occur, otherwise false.
  */
  parseSearchQuery(){
    try{
      let i;
      //Clear anything in the existing array.
      this.terms = [];
      this.normalizedQuery = [];
      let strSearch = this.queryBox.value;

      //Normalize unicode of course
      strSearch = strSearch.normalize('NFC');

      //Call the overridable function so end-users can specify their own
      //tweaks.
      strSearch = this.preProcessSearchString(strSearch);

      //Start by normalizing whitespace.
      strSearch = strSearch.replace(/((^\s+)|\s+$)/g, '');
      strSearch = strSearch.replace(/\s+/g, ' ');

      //Next, replace curly apostrophes with straight.
      strSearch = strSearch.replace(/[‘’‛]/g, "'");
      
      //Then remove any leading or trailing apostrophes
      strSearch = strSearch.replace(/(^'|'$)/g,'');

      //Now escape ampersands.
      strSearch = strSearch.replace(/&/g, '&amp;');

      //If we're not supporting phrasal searches, get rid of double quotes.
      if (!this.allowPhrasal){
        strSearch = strSearch.replace(/"/g, '');
      }
      //Otherwise, we rationalize the quotation marks
      else{
      //Get rid of any quote pairs with nothing between them.
        strSearch = strSearch.replace(/""/g, '');
        //Now delete any unmatched double quotes
        let qCount = 0;
        let lastQPos = -1;
        let tmp = '';
        for (i=0; i<strSearch.length; i++){
          tmp += strSearch.charAt(i);
          if (strSearch.charAt(i) === '"'){
            qCount++;
            lastQPos = i;
          }
        }
        if (qCount % 2 > 0){
          strSearch = tmp.substring(0, lastQPos) + tmp.substring(lastQPos + 1, tmp.length);
        }
        else{
          strSearch = tmp;
        }
      }

      //Now iterate through the string, paying attention
      //to whether you're inside a quote or not.
      let inPhrase = false;
      let strSoFar = '';
      for (let i=0; i<strSearch.length; i++){
        let c = strSearch.charAt(i);
        if (c === '"'){
          this.addSearchItem(strSoFar, inPhrase);
          inPhrase = !inPhrase;
          strSoFar = '';
        }
        else{
          // If we're not in a phrase, and encounter some sort of punctuation, then skip it
          if (this.charsToDiscardPattern.test(c) && (!inPhrase)) {
            // Just skip the bit of punctuation
          } else if ((c === ' ') && (!inPhrase)){
            this.addSearchItem(strSoFar, false);
            strSoFar = '';
          } else{
            strSoFar += c;
          }
        }
      }
      this.addSearchItem(strSoFar, inPhrase);
     
      // Now clear the queryBox and replace its contents
      // by joining the normalized query, and putting 
      // any ampersands back where they were.
      this.queryBox.value = this.normalizedQuery.join(" ").replace(/&amp;/, '&');
      

      //We always want to handle the terms in order of
      //precedence, starting with phrases.
      
      this.terms.sort(function(a, b){return a.type - b.type;});
      
      //return (this.terms.length > 0);
      //Even if we found no terms to search for, we should go
      //ahead with the search, either listing all the documents
     //or listing them based on the filters.
      return true;
    }
    catch(e){
      console.log('ERROR: ' + e.message);
      return false;
    }

  }

/** @function StaticSearch~addSearchItem
  * @description this is passed a single component from the
  * search box parser by parseSearchQuery. It constructs a
  * single item from it, and adds that to this.terms.
  * @param {!string}   strInput a string of text.
  * @param {!boolean}  isPhrasal whether or not this is a phrasal
  *                             search. This may be true even for
  *                             a single word, if it is to be searched
  *                             unstemmed.
  * @return {boolean} true if terms found, otherwise false.
  */
  addSearchItem(strInput, isPhrasal){


    //Sanity check
    if (strInput.length < 1){
      return false;
    }

    //Broadness check
    if (!isPhrasal && !this.termPattern.test(strInput)){
      this.normalizedQuery.push(strInput);
      this.discardedTerms.push(strInput);
      return false;
    }

    //Stopword check
    if (this.stopwords.indexOf(strInput.toLowerCase()) > -1){
      this.normalizedQuery.push(strInput);
      this.discardedTerms.push(strInput);
      return false;
    }

    //Is it a phrase?
    if ((/\s/.test(strInput)) || (isPhrasal)){

    // If this is a phrasal, we need to surround with quotation marks
    // before we push to the normalized query
    this.normalizedQuery.push('"' + strInput + '"');

    //We need to find the first component which is not a stopword.
    /** @suppress {missingProperties} Compiler doesn't know about String.prototype.replaceAll(). */
      let subterms = strInput.trim().toLowerCase().split(/\s+/).map(term => term.replaceAll(this.charsToDiscardPattern,''));
      let i;
      for (i = 0; i <= subterms.length; i++){
        if (this.stopwords.indexOf(subterms[i]) < 0){
          break;
        }
      }
      if (i < subterms.length){
        this.terms.push({str: strInput, stem: this.stemmer.stem(subterms[i]), type: PHRASE});

      }
    }
    else{
      //Push the string to the normalized query
      this.normalizedQuery.push(strInput);
      //Else is it a wildcard? Wildcards are expanded to a sequence of matching terms.
      if (this.allowWildcards && /[\[\]?*]/.test(strInput)){
        let re = this.wildcardToRegex(strInput);
        let matches = [...this.wordString.matchAll(re)];
        //Now we have a nested array of matches. We need to stem and filter.
        let stems = [];
        for (let m of matches){
          let mStem = this.stemmer.stem(m[1].toLowerCase());
          let term = m[0].replace(/[\|]/g, '');
          if (this.terms.length < this.termLimit){
            if (this.allowPhrasal){
              this.terms.push({str: term, stem: mStem, type: PHRASE});
            }
            else{
              this.terms.push({str: term, stem: mStem, type: MAY_CONTAIN});
            }
          }
        }
      }
      else{
        //Else is it a must-contain?
        if (/^[\+]/.test(strInput)){
          let term = strInput.substring(1).toLowerCase();
          this.terms.push({str: strInput.substring(1), stem: this.stemmer.stem(term), type: MUST_CONTAIN});
        }
        else{
        //Else is it a must-not-contain?
          if (/^[\-]/.test(strInput)){
            let term = strInput.substring(1).toLowerCase();
            this.terms.push({str: strInput.substring(1), stem: this.stemmer.stem(term), type: MUST_NOT_CONTAIN});
          }
          else{
          //Else may-contain.
            let term = strInput.toLowerCase();
            this.terms.push({str: strInput, stem: this.stemmer.stem(term),  type: MAY_CONTAIN});
          }
        }
      }
    }
    return (this.terms.length > 0);
  }

/** @function StaticSearch~clearSearchForm
  * @description this function removes all previously-selected
  * filter control settings, and empties the search query box.
  *
  * @return {boolean} true on success, false on failure.
  */
  clearSearchForm(){
    try{
      this.queryBox.value = '';

      for (let cbx of this.searchInFilterCheckboxes){
        cbx.checked = false;
      }

      for (let cbx of this.descFilterCheckboxes){
        cbx.checked = false;
      }
      //Feature filter checkboxes need to be discovered first, since 
      //they're mutable.
      this.featFilterCheckboxes = 
        Array.from(document.querySelectorAll("input[type='checkbox'].staticSearch_feat"));
      for (let cbx of this.featFilterCheckboxes){
        cbx.checked = false;
      }  
      for (let txt of this.dateFilterTextboxes){
        txt.value = '';
      }
      for (let num of this.numFilterInputs){
        num.value = '';
      }
      for (let sel of this.boolFilterSelects){
        sel.selectedIndex = 0;
      }
      for (let txt of this.featFilterInputs){
        txt.value = '';
      }
      //Clear the search params in the URL too.
      let url = window.location.href.split(/[?#]/)[0];
      history.pushState({time: Date.now()}, '', url);

    //Emit an event to notify that the form has been cleared.
    window.dispatchEvent(new CustomEvent('ssFormCleared'));
      return true;
    }
    catch(e){
      console.log('Error attempting to clear search form: ' + e);
      return false;
    }
  }

/** @function StaticSearch~processFilters
  * @description this function calls StaticSearch~getDocUrisForFilters(),
  * and if the function succeeds, it sets the docsMatchingFilters to
  * the returned XSet and returns true, otherwise it clears the current
  * set of filters (THINK: IS THIS CORRECT BEHAVIOUR?) and returns false.
  *
  * @return {boolean} true on success, false on failure.
  */
  processFilters(){
    try{
      this.docsMatchingFilters = this.getDocUrisForFilters();
      this.activeContexts = new XSet(this.searchInFilterCheckboxes.filter(cbx => cbx.checked).map(c => c.id));
      return true;
    }
    catch(e){
      console.log('Error attempting to generate the set of docs matching filters: ' + e);
      return false;
    }
  }

  /** @function StaticSearch~getDocUrisForFilters
    * @description this function gets the set of currently-configured
    * filters by analyzing the form elements, then returns a
    * set (in the form of an XSet object) of all the document ids
    * that qualify according to the filters.
    *
    * @return {XSet} an XSet object (which might be empty) with an added
    * boolean property filtersActive which specifies whether filters have
    * been configured by the user.
    * @suppress {missingProperties} The compiler doesn't know about the 
    * docs property.
    */
    getDocUrisForFilters(){

      var xSets = [];
      var currXSet;

      //Find each desc or feat fieldset and get its descriptor.
      let filters = document.querySelectorAll('fieldset[id ^= "ssDesc"], fieldset[id ^="ssFeat"]');
      for (let filter of filters){
        currXSet = new XSet();
        let filterName = filter.getAttribute('title');
        let cbxs = filter.querySelectorAll('input[type="checkbox"]:checked');
        if ((cbxs.length > 0) && (this.mapFilterData.has(filterName))){
          for (let cbx of cbxs){
            currXSet.addArray(this.mapFilterData.get(filterName)[cbx.id].docs);
          }
          xSets.push(currXSet);
        }
      }

      //Find each bool selector and get its descriptor.
      let bools = document.querySelectorAll('select[id ^= "ssBool"]');
      for (let bool of bools){
        let sel = bool.selectedIndex;
        let valueId = bool.id + '_' + bool.selectedIndex;
        let boolName = bool.getAttribute('title');
        if ((sel > 0) && (this.mapFilterData.has(boolName)) && (this.mapFilterData.get(boolName)[valueId] !== undefined)){
          currXSet = new XSet();
          currXSet.addArray(this.mapFilterData.get(boolName)[valueId].docs);
          xSets.push(currXSet);
        }
      }

      //Find each date pair and get its descriptor.
      let dates = document.querySelectorAll('fieldset[id ^= "ssDate"]');
      for (let date of dates){
        let dateName = date.title;
        if (this.mapFilterData.has(dateName)){
          let docs = this.mapFilterData.get(dateName).docs;
          //If it's a from date, partial dates are OK because the date constructor
          //defaults to -01-01.
          let fromDate = null;
          let toDate = null;
          let fromVal = date.querySelector('input[type="text"][id $= "_from"]').value;
          if (fromVal.length > 0){
            currXSet = new XSet();
            fromDate = new Date(fromVal);
            for (const docUri in docs){
              if ((docs[docUri].length > 0) && (new Date(docs[docUri][docs[docUri].length-1]) >= fromDate)){
                currXSet.add(docUri);
              }
            }
            xSets.push(currXSet);
          }
          //If it's a to date, we have to append stuff.
          let toVal = date.querySelector('input[type="text"][id $= "_to"]').value;
          if (toVal.length > 0){
            currXSet = new XSet();
            switch (toVal.length){
              case 10: toDate = new Date(toVal); break;
              case 4:  toDate = new Date(toVal + '-12-31'); break;
              case 7:  toDate = new Date(toVal.replace(/(\d\d\d\d-)((0[13578])|(1[02]))$/, '$1$2-31').replace(/(\d\d\d\d-)((0[469])|(11))$/, '$1$2-30').replace(/02$/, '02-28')); break;
              default: toDate = new Date('3000'); //random future date.
            }
            for (const docUri in docs){
              if ((docs[docUri].length > 0) && (new Date(docs[docUri][0]) <= toDate)){
                currXSet.add(docUri);
              }
            }
            xSets.push(currXSet);
          }
        }
      }

      //Find each number pair and get its descriptor.
      let nums = document.querySelectorAll('fieldset[id ^= "ssNum"]');
      for (let num of nums){
        let numName = num.title;
        if (this.mapFilterData.has(numName)){
          let docs = this.mapFilterData.get(numName).docs;
          let fromNum = null;
          let toNum = null;
          let fromVal = num.querySelector('input[type="number"][id $= "_from"]').value;
          if (fromVal.length > 0){
            currXSet = new XSet();
            fromNum = parseFloat(fromVal);
            for (const docUri in docs){
              if ((docs[docUri].length > 0) && (parseFloat(docs[docUri][docs[docUri].length-1]) >= fromNum)){
                currXSet.add(docUri);
              }
            }
            xSets.push(currXSet);
          }
          let toVal = num.querySelector('input[type="number"][id $= "_to"]').value;
          if (toVal.length > 0){
            currXSet = new XSet();
            toNum = parseFloat(toVal);
            for (const docUri in docs){
              if ((docs[docUri].length > 0) && (parseFloat(docs[docUri][0]) <= toNum)){
                currXSet.add(docUri);
              }
            }
            xSets.push(currXSet);
          }
        }
      }

      if (xSets.length > 0){
        let result = xSets[0];
        for (var i=1; i<xSets.length; i++){
          result = result.intersection(xSets[i]);
        }
        result.filtersActive = true;
        return result;
      }
      else{
      //This represents a situation in which we appear to have filters active,
      //but they don't match any of the known types, so behave as though no
      //filters were specified.
        let result = new XSet();
        result.filtersActive = false;
        return result;
      }
    }

/** @function StaticSearch~writeSearchReport
  * @description This outputs a human-readable explanation of the search
  *              that's being done, to clarify for users what they've chosen 
  *              to look for. Note that the output div is hidden by default. 
  *              NOTE: This does not yet include filter information.
  * @return {boolean} true if the process succeeds, otherwise false.
  */
  writeSearchReport(){
    if (this.showSearchReport){
      try{
        let sr = document.querySelector('#searchReport');
        if (sr){sr.parentNode.removeChild(sr);}
        let arrOutput = [];
        let i, d, p, t;
        for (i=0; i<this.terms.length; i++){
          if (!arrOutput[this.terms[i].type]){
            arrOutput[this.terms[i].type] = {type: this.terms[i].type, terms: []};
          }
          arrOutput[this.terms[i].type].terms.push(`"${this.terms[i].str}" (${this.terms[i].stem})`);
        }
        arrOutput.sort(function(a, b){return a.type - b.type;})

        d = document.createElement('div');
        d.setAttribute('id', 'searchReport');

        arrOutput.forEach((obj)=>{
          p = document.createElement('p');
          t = document.createTextNode(this.captionSet[obj.type] + obj.terms.join(', '));
          p.appendChild(t);
          d.appendChild(p);
        });
        //this.resultsDiv.insertBefore(d, this.resultsDiv.firstChild);
        this.resultsDiv.parentNode.insertBefore(d, this.resultsDiv);
        return true;
      }
      catch(e){
        console.log('ERROR: ' + e.message);
        return false;
      }
    }
    return true;
  }

/**
  * @function StaticSearch~getTermsByType
  * @description This method returns an array of indexes in the
  * StaticSearch.terms array, being the terms which match the
  * supplied term type (PHRASE, MUST_CONTAIN etc.).
  * @param {!number} termType One of PHRASE, MUST_CONTAIN, MUST_NOT_CONTAIN,
                              MAY_CONTAIN.
  * @return {!Array<number>} An array of zero or more integers.
  */
  getTermsByType(termType){
    let result = [];
    for (let i=0; i<this.terms.length; i++){
      if (this.terms[i].type == termType){
        result.push(i);
      }
    }
    return result;
  }

/**
  * @function StaticSearch~populateIndexes
  * @description The task of this function is basically
  * to ensure that the various indexes (search terms and facet filters)
  * are ready to handle a search, in that attempts have been made to
  * retrieve all JSON files relating to the current search.
  * The index is deemed ready when either a) all the JSON files
  * for required stems and filters have been retrieved and their
  * contents merged into the required structures, or b) a retrieval
  * has failed, so an empty placeholder has been inserted to signify
  * that there is no such dataset.
  *
  * The function works with fetch and promises, and its final
  * .then() calls the processResults function.
  * @suppress {missingProperties} The compiler doesn't know about
  * properties such as json.filterId.
  */
  populateIndexes(){
    var i, imax, stemsToFind = [], promises = [], emptyIndex, filterSelector, filterIds;
//We need a self pointer because this will go out of scope.
    var self = this;
    try{
  //For each stem in the search string
      for (i=0, imax=this.terms.length; i<imax; i++){
  //Now check whether we already have an index entry for this stem
        if (!this.index.hasOwnProperty(this.terms[i].stem)){
  //If not, add it to the array of stems we want to retrieve.
          stemsToFind.push(this.terms[i].stem);
        }
      }

      filterIds = new Set();
      //Do we need to get document metadata for filters?
      if (this.allJsonRetrieved === false){
        //First get a list of active filters.

        for (let ctrl of document.querySelectorAll('input[type="checkbox"].staticSearch_desc:checked, input[type="checkbox"].staticSearch_feat:checked')){
          let filterId = ctrl.id.split('_')[0];
          if (this.mapJsonRetrieved.get(filterId) != GOT){
            filterIds.add(filterId);
          }
        }
        for (let ctrl of document.querySelectorAll('select.staticSearch_bool')){
          if (ctrl.selectedIndex > 0){
            let filterId = ctrl.id.split('_')[0];
            if (this.mapJsonRetrieved.get(filterId) != GOT){
              filterIds.add(filterId);
            }
          }
        }
        for (let ctrl of document.querySelectorAll('input[type="text"].staticSearch_date')){
          if (ctrl.value.length > 3){
            let filterId = ctrl.id.split('_')[0];
            if (this.mapJsonRetrieved.get(filterId) != GOT){
              filterIds.add(filterId);
            }
          }
        }
        for (let ctrl of document.querySelectorAll('input[type="number"].staticSearch_num')){
          if (ctrl.value.length > 0){
            let filterId = ctrl.id.split('_')[0];
            if (this.mapJsonRetrieved.get(filterId) != GOT){
              filterIds.add(filterId);
            }
          }
        }
        //Create promises for all of the required filters.
        for (let filterId of filterIds){
          promises[promises.length] = fetch(self.jsonDirectory + 'filters/' + filterId + this.versionString + '.json', this.fetchHeaders)
            .then(function(response) {
              return response.json();
            })
            .then(function(json) {
              self.mapFilterData.set(json.filterName, json);
              self.mapJsonRetrieved.set(json.filterId, GOT);
            }.bind(self))
            .catch(function(e){
              console.log('Error attempting to retrieve filter data: ' + e);
            }.bind(self));
        }
        //What else do we need to retrieve?

        //Get the stopwords if needed.
        if (this.mapJsonRetrieved.get('ssStopwords') != GOT){
          promises[promises.length] = fetch(self.jsonDirectory + 'ssStopwords' + this.versionString + '.json', this.fetchHeaders)
            .then(function(response) {
              return response.json();
            })
            .then(function(json) {
              self.stopwords = json.words;
              self.mapJsonRetrieved.set('ssStopWords', GOT);
            }.bind(self))
            .catch(function(e){
              console.log('Error attempting to retrieve stopword list: ' + e);
            }.bind(self));
        }

        if (this.mapJsonRetrieved.get('ssTitles') != GOT){
          promises[promises.length] = fetch(self.jsonDirectory + 'ssTitles' + this.versionString + '.json', this.fetchHeaders)
            .then(function(response) {
              return response.json();
            })
            .then(function(json) {
              /** @suppress {checkTypes} The compiler doesn't know the json thing is an object with entries. */
              self.resultSet.titles = new Map(Object.entries(json));
              self.mapJsonRetrieved.set('ssTitles', GOT);
            }.bind(self))
            .catch(function(e){
              console.log('Error attempting to retrieve title list: ' + e);
            }.bind(self));
        }
//For glob searching, we'll need to care about the string of words too.
        if (this.allowWildcards == true){
          if (this.mapJsonRetrieved.get('ssWordString') != GOT){
            promises[promises.length] = fetch(self.jsonDirectory + 'ssWordString' + this.versionString + '.txt', this.fetchHeaders)
              .then(function(response) {
                return response.text();
              })
              .then(function(text) {
                self.wordString = text;
                self.mapJsonRetrieved.set('ssWordString', GOT);
              }.bind(self))
              .catch(function(e){
                console.log('Error attempting to retrieve word string: ' + e);
              }.bind(self));
          }
        }
      }

      //If we do need to retrieve JSON index data, then do it
      if (stemsToFind.length > 0){

//Set off fetch operations for the things we don't have yet.
        for (i=0, imax=stemsToFind.length; i<imax; i++){

//We will first add an empty index so that if nothing is found, we won't need
//to search again.
          emptyIndex = {'stem': stemsToFind[i], 'instances': []}; //used as return value when nothing retrieved.

          this.stemFound(emptyIndex);

//We create an array of fetches to get the json file for each stem,
//assuming it's there.
          promises[promises.length] = fetch(self.jsonDirectory + 'stems/' + stemsToFind[i] + this.versionString + '.json', this.fetchHeaders)
//If we get a response, and it looks good
              .then(function(response){
                if ((response.status >= 200) &&
                    (response.status < 300) &&
                    (response.headers.get('content-type')) &&
                    (response.headers.get('content-type').includes('application/json'))) {
//then we ask for response.json(), which is itself a promise, to which we add a .then to store the data.
                  return response.json().then(function(data){ self.stemFound(data); }.bind(self));
                }
              })
//If something goes wrong, then we store an empty index
//through the notFound function.
              .catch(function(e){
                console.log('Error attempting to retrieve ' + stemsToFind[i] + ': ' + e);
                return function(emptyIndex){self.stemFound(emptyIndex);}.bind(self, emptyIndex);
              }.bind(self));
            }
      }

      //Now set up a Promise.all to fire the rest of the work when all fetches have
      //completed or failed.
      if (promises.length > 0){
        Promise.all(promises).then(function(values) {
          this.processResults();
        }.bind(self));
      }
      //Otherwise we can just do the search with the index data we already have.
      else{
        setTimeout(function(){this.processResults();}.bind(self), 0);
      }
    }
    catch(e){
      console.log('ERROR: ' + e.message);
    }
  }

/**
  * @function StaticSearch~stemFound
  * @description Before a request for a JSON file is initially made,
  *              an empty index is stored, indexed under the stem
  *              which is being searched, so that whether or not we
  *              successfully retrieve data, we won't have to try
  *              again in a subsequent search in the same session.
  *              Then, when a request for a JSON file for a specific
  *              stem results in a JSON file with data, we overwrite
  *              the data in the index, indexed under the stem.
  *              Sometimes the data coming in may be an instance
  *              of an empty index, if the retrieval code knows it
  *              got nothing.
  * @param {Object} data the data structure retrieved for the stem.
  */
  stemFound(data){
    try{
      this.index[data.stem] = data;
    }
    catch(e){
      console.log('ERROR: ' + e.message);
    }
  }

/**
  * @function staticSearch~indexStemHasDoc
  * @description This function, given an index stem and a docUri, searches
  *              to see if there is an entry in the stem's instances for
  *              that docUri.
  * @param {!string} stem the index stem to search for.
  * @param {!string} docUri the docUri to search for.
  * @return {boolean} true if found, false if not.
  */
  indexStemHasDoc(stem, docUri){
    let result = false;
    if (this.index[stem]){
      for (let i=0; i<this.index[stem].instances.length; i++){
        if (this.index[stem].instances[i].docUri == docUri){
          result = true;
          break;
        }
      }
    }
    return result;
  }

/**
  * @function StaticSearch~clearResultsDiv
  * @description This clears out and sets up the results div, ready for
  * reporting of results.
  * @return {boolean} true if successful, false if not.
  */
  clearResultsDiv(){
    while (this.resultsDiv.firstChild) {
      this.resultsDiv.removeChild(this.resultsDiv.firstChild);
    }
    return true;
  }


/**
  * @function StaticSearch~reportNoResults
  * @description Reports that no results have been found.
  *              Also optionally configures and runs a
  *              simpler version of the current search, with
  *              phrases tokenized, etc.
  * @param {!boolean} trySimplerSearch a flag to determine whether
  *              this search should be simplified and automatically
  *              run again.
  * @return {boolean} true if successful, false if not.
  */
  reportNoResults(trySimplerSearch){
    //TODO: NOT IMPLEMENTED YET.
    console.log('No results. Try simpler search? ' + trySimplerSearch);
    return true;
  }

  /**
   * @function StaticSearch~reportTooManyResults
   * @description Reports, both in the results and the console,
   *              that the number of results found exceed
   *              the configured limit (StaticSearch.resultsLimit)
   *              and cannot be displayed.
   * @return {boolean} true if successful, false if not
   */
  reportTooManyResults() {
    try {
      console.log(`Found ${this.resultSet.getSize()} results, which exceeds the ${this.resultsLimit} maximum.`);
      let pTooManyResults = document.createElement('p');
      pTooManyResults.append(this.captionSet.strTooManyResults);
      this.resultsDiv.appendChild(pTooManyResults);
      //Emit an event to notify that the search is completed, including the hit count.
      window.dispatchEvent(new CustomEvent('ssSearchCompleted', {detail: {'hits': this.resultSet.getSize()}}));
      return true;
    } catch (e) {
      console.log('ERROR: ' + e);
      return false;
    }
  }


  /**
  * @function StaticSearch~processResults
  * @description When we are satisfied that all relevant search data
  *              has been retrieved and added to the index, this
  *              function is called to process the search and show
  *              any results found.
  * @return {boolean} true if there are results to show; false if not.
  */
  processResults(){
    try{

//Start by clearing any previous results.
      this.resultSet.clear();

//Process any filters that may be active.
      this.processFilters();

//Now we have to fork, depending on whether we have search terms and filters
//or not. There are several scenarios:
/*
  1. There are active filters and also search terms.
  2. There are search terms but no active filters.
  3. There are active filters but no search terms
     (although search terms may have been discarded).
  4. There are no active filters and no search terms 
     (although search terms may have been discarded).

  For #1, process the term searches into the result set, and then
     filter it using the active filter matching doc list.
  For #2, process the results into the result set, but don't filter it.
  For #3, construct the result set directly from the filter doc list,
     passing only ids and titles, for a simple listing display.
  For #4, do nothing at all (or possibly display an error message).

  For cases #1 and #2 (i.e. where there is a search term), there may be
  active context filters; those are a bit different, since they do not require
  any fetching (all of that information is contained within the JSON).

  */
//Since we have to handle discarded search terms in the same
//manner whatever the scenario, we do them first.
let pDiscarded = null;
if (this.discardedTerms.length > 0){
  let txt = this.captionSet.strDiscardedTerms + ' ' + this.discardedTerms.join(', ');
  pDiscarded = document.createElement('p');
  pDiscarded.classList.add('ssDiscarded');
  pDiscarded.append(txt);
  //pDiscarded.appendChild(txt);
}

//Easy ones first: #4
      if ((this.terms.length < 1)&&(this.docsMatchingFilters.size < 1)){

        this.clearResultsDiv();
        if (pDiscarded !== null){
          this.resultsDiv.appendChild(pDiscarded);
        }
        let pFound = document.createElement('p');
        pFound.append(this.captionSet.strDocumentsFound + '0');
        this.resultsDiv.appendChild(pFound);
        this.isSearching = false;
        this.searchFinishedHook(1);
        return false;
      }
//#3
      if ((this.terms.length < 1)&&(this.docsMatchingFilters.size > 0)){
        this.resultSet.addArray([...this.docsMatchingFilters]);
        this.resultSet.sortByScoreDesc();

        this.clearResultsDiv();
        if (pDiscarded !== null){
          this.resultsDiv.appendChild(pDiscarded);
        }
        let pFound = document.createElement('p');
        pFound.append(this.captionSet.strDocumentsFound + this.resultSet.getSize());
        this.resultsDiv.appendChild(pFound);
        //Switch depending on the result size:
        //Report that there are no results
        if (this.resultSet.getSize() < 1){
          this.reportNoResults(true);
          // Else if the number of results is greater than the limit.
        } else if (this.resultSet.getSize() > this.resultsLimit){
            this.reportTooManyResults();
        } else {
          // Otherwise, render the results, optionally paginated.
          this.resultsDiv.appendChild(this.resultSet.resultsAsHtml(this.captionSet.strScore));
          if (this.resultsPerPage > 0 && this.resultsPerPage < this.resultSet.getSize()){
            this.paginateResults();
          }
        }
        this.isSearching = false;
        this.searchFinishedHook(2);
        return (this.resultSet.getSize() > 0);
      }

//The sequence of result processing is highly dependent on the
//query components entered by the user. First, we discover what
//term types we have in the list.
      /** @type {!Array<number>} */
      let phrases           = this.getTermsByType(PHRASE);
      /** @type {!Array<number>} */
      let must_contains     = this.getTermsByType(MUST_CONTAIN);
      /** @type {!Array<number>} */
      let must_not_contains = this.getTermsByType(MUST_NOT_CONTAIN);
      /** @type {!Array<number>} */
      let may_contains      = this.getTermsByType(MAY_CONTAIN);

//For nested functions, we need a reference to this.
      var self = this;

//Now we have a few embedded functions to avoid duplicating code.
/**
  * @function StaticSearch~processResults~processPhrases
  * @description Embedded function to retrieve the results from
  *              phrasal searches.
  * @return true if succeeds, false if not.
  */
      function processPhrases(){
        try{
          for (let phr of phrases){
  //Get the term we decided to use to retrieve index data.
            let stem = self.terms[phr].stem;
            let str = self.terms[phr].str;
            let phraseRegex = self.phraseToRegex(str);
  //If that term is in the index (it should be, even if it's empty, but still...)
            if (self.index[stem]){
  //Look at each of the document instances for that term...
              for (let inst of self.index[stem].instances){
  //Create an array to hold the contexts
                let currContexts = [];
  //Now look at each context for that instance, if any...
                for (let cntxt of inst.contexts){
  //Check whether our phrase matches that context (remembering to strip
  //out any <mark> tags)...
                  let unmarkedContext = cntxt.context.replace(/<[^>]+>/g, '');
                  if (phraseRegex.test(unmarkedContext)){
  //We have a candidate document for inclusion, and a candidate context.
                    let c = unmarkedContext.replace(phraseRegex, '<mark>' + '$&' + '</mark>');
                    currContexts.push(
                    {form: str, context: c, weight: 2, fid: cntxt.fid ? cntxt.fid : '', prop: cntxt.prop ? cntxt.prop : {}, in: cntxt.in ? cntxt.in : []});
                  }
                }
  //If we've found contexts, we know we have a document to add to the results.
                if (currContexts.length > 0){
  //The resultSet object will automatically merge this data if there's already
  //an entry for the document.
                  self.resultSet.set(inst.docUri, {docUri: inst.docUri,
                    docTitle: inst.docTitle,
                    //score: inst.score, //See below: which is right? TODO.
                    contexts: currContexts,
                    score: currContexts.length});
                }
              }
            }
          }
          return true;
        }
        catch(e){
          console.log('ERROR: ' + e.message);
          return false;
        }
      }
//End of nested function processPhrases.

/**
  * @function StaticSearch~processResults~processMustNotContains
  * @description Embedded function to remove from the result set all
  *              documents which contain terms which have been designated
  *              as excluded.
  * @return true if succeeds, false if not.
  */
      function processMustNotContains(){
        try{
          for (let mnc of must_not_contains){
            let stem = self.terms[mnc].stem;
            if (self.index[stem]){
//Look at each of the document instances for that term...
              for (let inst of self.index[stem].instances){
//Delete it from the result set.
                if (self.resultSet.has(inst.docUri)){
                  self.resultSet.delete(inst.docUri);
                }
              }
            }
          }
          return true;
        }
        catch(e){
          console.log('ERROR: ' + e.message);
          return false;
        }
      }
//End of nested function processMustNotContains.

/**
  * @function StaticSearch~processResults~processMustContains
  * @description Embedded function to retrieve all documents containing
  *              terms designated as required. This function works in
  *              two ways; if running after a phrasal search has been
  *              done, it simply acts as a filter on the document set
  *              already retrieved; if running as the initial retrieval
  *              mechanism (where there are no phrasal searches), it
  *              populates the result set itself. It's doubly complicated
  *              because it must also eliminate from the existing result
  *              set any document that doesn't contain a term.
  * @param {!Array<number>} indexes a list of indexes into the terms array.
  *              This needs to be a parameter because the function is calls
  *              itself recursively with a reduced array.
  * @param {!boolean} runAsFilter controls which mode the process runs in.
  * @return true if succeeds, false if not.
  */
      function processMustContains(indexes, runAsFilter){
        try{
          if (runAsFilter){
            if (self.resultSet.getSize() < 1){
              return true; //nothing to do.
            }
            for (let must_contain of indexes){
              let stem = self.terms[must_contain].stem;
              if (self.index[stem]){
//Look at each of the document instances for that term...
                for (let inst of self.index[stem].instances){
//We only include it if if matches a document already found for a phrase
//or the first must_contain.
                  if (self.resultSet.has(inst.docUri)){
                    self.resultSet.merge(inst.docUri, inst);
                  }
                }
              }
            }
  //Now weed out results which don't have matches in other terms.
            let docUrisToDelete = [];
            for (let docUri of self.resultSet.mapDocs.keys()){
              for (let mc of must_contains){
                if (! self.indexStemHasDoc(self.terms[mc].stem, docUri)){
                  docUrisToDelete.push(docUri);
                }
              }
            }
            self.resultSet.deleteArray(docUrisToDelete);
          }
          else{
//Here we start by processing the first only.
            let stem = self.terms[0].stem;
            if (self.index[stem]){
            //Look at each of the document instances for that term...
              for (let inst of self.index[stem].instances){
                self.resultSet.set(inst.docUri, inst);
              }
            }
            processMustContains(must_contains.slice(1), true);
          }
          return true;
        }
        catch(e){
          console.log('ERROR: ' + e.message);
          return false;
        }
      }
//End of nested function processMustContains.

/**
  * @function StaticSearch~processResults~processMayContains
  * @description Embedded function to process may_contain search terms.
  *              This function runs in two modes: if it's being called
  *              after prior imperative search terms have been processed,
  *              then it adds no new documents to the set, just enhances
  *              their scores. But if there are no imperative search
  *              terms, then all documents found are added to the set.
  * @param {!boolean} addAllFound controls which mode the process runs in.
  * @return true if succeeds, false if not.
  */
      function processMayContains(addAllFound){
        for (let may_contain of may_contains){
          let stem = self.terms[may_contain].stem;
          if (self.index[stem]){
//Look at each of the document instances for that term...
            for (let inst of self.index[stem].instances){
//We only include it if if matches a document already found for a phrase.
              if ((self.resultSet.has(inst.docUri))||(addAllFound)){
//We can call set() here, since the result set will merge if necessary.
                self.resultSet.set(inst.docUri, inst);
              }
            }
          }
        }
      }
//End of nested function processMayContains.

//Main function code resumes here.
      if (phrases.length > 0){
//We have phrases. They take priority. Get results if there are any.
//For each phrase we're looking for...
        processPhrases();
//Continue, because we have results. Now we process any must_not_contains.
        processMustNotContains();

//We can continue. Now we check for any must_contains.
        processMustContains(must_contains, true);

//Finally the may_contains.
        processMayContains(false);
      }
      else{
        if (must_contains.length > 0){
//We have no phrases, but we do have musts, so these are the priority.
          processMustContains(must_contains, false);
//Now we trim down the dataset using any must_not_contains.
          processMustNotContains();
//Finally the may_contains.
          processMayContains(false);
        }
        else{
          if (may_contains.length > 0){
            //We have no phrases or musts, so we fall back to mays.
            processMayContains(true);
            processMustNotContains();
          }
          else{
            console.log('No useful search terms found.');
            this.isSearching = false;
            this.searchFinishedHook(3);
            return false;
          }
        }
      }

//Now we filter the results based on filter checkboxes, if any.
//This is #1
      if (this.docsMatchingFilters.filtersActive == true){
        this.resultSet.filterBySet(this.docsMatchingFilters);
      }

      // Now process the resultSet and filter out any contexts
      // and docs that by active contexts, if any
      if (this.activeContexts.size > 0){
   
        this.resultSet.filterByContexts(this.activeContexts);
      }


      this.resultSet.sortByScoreDesc();
      this.clearResultsDiv();
      if (pDiscarded !== null){
        this.resultsDiv.appendChild(pDiscarded);
      }
      let pFound = document.createElement('p');
      pFound.append(this.captionSet.strDocumentsFound + this.resultSet.getSize());
      this.resultsDiv.appendChild(pFound);
      //Switch depending on the result size:
      //Report that there are no results
      if (this.resultSet.getSize() < 1){
        this.reportNoResults(true);
        // Else if the number of results is greater than the limit.
      } else if (this.resultSet.getSize() > this.resultsLimit){
        this.reportTooManyResults();
      } else {
        // Otherwise, render the results, optionally paginated.
        this.resultsDiv.appendChild(this.resultSet.resultsAsHtml(this.captionSet.strScore));
        if (this.resultsPerPage > 0 && this.resultsPerPage < this.resultSet.getSize()){
          this.paginateResults();
        }
      }
      this.isSearching = false;
      this.searchFinishedHook(4);
      //Emit an event to notify that the search is completed, including the hit count.
      window.dispatchEvent(new CustomEvent('ssSearchCompleted', {detail: {'hits': this.resultSet.getSize()}}));
      return (this.resultSet.getSize() > 0);
    }
    catch(e){
      console.log('ERROR: ' + e.message);
      this.isSearching = false;
      this.searchFinishedHook(5);
      return false;
    }
  }


  /**
   * @function StaticSearch~paginateResults
   * @description This method adds pagination controls to the results and adds
   * a number of properties to the StaticSearch object to handle pagination. It first
   * checks whether or not it needs to add anything to the page, and, if it does,
   * then adds the Show More / Show All buttons to the bottom of the results div
   * and adds some functionality to the buttons.
   * @return {boolean} true if necessary; false if unnecessary
   */
  paginateResults() {
    try{
      // Get the list of all result items using the configured selector; we do this here
      // in case ResultsAsHTML is modified in such a way that it invalidates the default
      // selector
      this.resultItems = this.resultsDiv.querySelectorAll(this.resultItemsSelector);

      // Construct all of the widgets (using the longhand createElement method, since
      // we have to hook event listeners to the buttons)
      this.paginationBtnDiv = document.createElement('div');
      this.paginationBtnDiv.setAttribute('id', 'ssPagination');
      this.showMoreBtn = document.createElement('button');
      this.showMoreBtn.setAttribute('id', 'ssShowMore');
      this.showMoreBtn.innerHTML = this.captionSet.strShowMore;
      this.showAllBtn = document.createElement('button');
      this.showAllBtn.setAttribute('id', 'ssShowAll');
      this.showAllBtn.innerHTML = this.captionSet.strShowAll;
      this.paginationBtnDiv.appendChild(this.showMoreBtn);
      this.paginationBtnDiv.appendChild(this.showAllBtn);
      this.resultsDiv.appendChild(this.paginationBtnDiv);

      // Now start the pagination
      this.showMoreResults();

      // And add the pagination functions to the respective buttons
      this.showMoreBtn.addEventListener('click', this.showMoreResults.bind(this));
      this.showAllBtn.addEventListener('click', this.showAllResults.bind(this));
      return true;
    } 
    catch(e) {
      console.log('ERROR ' + e.message);
      return false;
    }
  }

  /**
   * @function StaticSearch~showAllResults
   * @description Method to show all of the results (i.e. removing the hidden item's
   * class that instructs all of its siblings to hide) and hide the pagination
   * widget.
   * @return {boolean} true if successful, false if not.
   */
  showAllResults(){
    try{
      this.currItem.classList.remove('ssPaginationEnd');
      this.paginationBtnDiv.style.display = "none";
      return true;
    } catch(e) {
      console.log('ERROR ' + e.message);
      return false;
    }

  }

  /**
   * @function StaticSearch~showMoreResults
   * @description Method to show more results based off of the current page
   * and the number of results to show. If we're on the last page, then the
   * "Show More" is simply a proxy for showAll; otherwise, it shifts the
   * hidden class from the last item to the next one in the sequence.
   * @return {boolean} true if successful, false if not.
   */
  showMoreResults(){
    try{
      this.currPage++;
      let nextItemNum = (this.currPage * this.resultsPerPage) - 1;
      if (this.currItem !== null){
        this.currItem.classList.remove('ssPaginationEnd');
      }
      if (nextItemNum >= this.resultSet.getSize()){
        this.showAllResults();
        return true;
      }
      this.currItem = this.resultItems[nextItemNum];
      this.currItem.classList.add('ssPaginationEnd');
      return true;
    } catch(e){
        console.log('ERROR ' + e.message);
        return false;
    }
  }


  /** @function StaticSearch~phraseToRegex
   *  @description This method takes a phrase and converts it
   *  into the regular expression that will be matched against
   *  contexts. This function first escapes all characters
   *  to prevent from unintentional regular expression, then expands all
   *  apostrophes (i.e. treating U+0027, U+2018, U+2019, U+201B as equivalent) and
   *  all quotation marks.
   * @param {!string} str a string of text
   * @return {RegExp|null} a regular expression, or null if one can't be constructed
   */
  phraseToRegex(str){
    //Escape the phrase to have proper punctuation matching
    let esc = str.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
    //Expand the apostrophes into a character class
    let strRe = esc.replace(/'/g, "['‘’‛]").replace(/[“”]/g, '[“”"]');
    //Set starting anchor
    if (/^\w/.test(str)){
      strRe = '\\b' + strRe;
    }
    //Set ending anchor
    if (/\w$/.test(str)){
      strRe = strRe + '\\b';
    }
    // Test the regex and return null if it's broken
    try{
      //Make the phrase into a regex for matching.
      let re = new RegExp(strRe);
      return re;
    }
    catch(e){
      console.log('Invalid regex from phrase created: ' + strRe);
      return null;
    }
  }


/** @function StaticSearch~wildcardToRegex
  * @description This method is provided with a single token as 
  * input. The token should contain wildcard characters (asterisk,
  * question mark and square brackets). The function converts this
  * to a JS regular expression. For example: th*n[gk]? would 
  * become /^th.*[gk].$/. The regex is created with leading and
  * trailing pipe characters, because the string of words against
  * which it will be matched uses these as delimiters, and it has
  * a capturing group for the content between the pipes. Because of
  * the use of the pipe delimiter, a negative character class [^\\|]
  * (i.e. 'not a pipe') is used in place of a dot.
  * @param {!string}   strToken a string of text with no spaces.
  * @return {RegExp | null} a regular expression; or null if one 
  *                         cannot be constructed.
  */

  wildcardToRegex(strToken){
    //First check that we have a proper token.
    if (strToken.match(/[\s"]]/)){
      return null;
    }
    //Generate the regex.
    let esc = strToken.replace(/[.+^${}()|\\]/g, '\\$&');
    let strRe  = esc.replace(/[\?]/g, '[^\\|]').replace(/[\*]/g, '[^\\|]$&?');
    //Test the regex, and return it if OK, otherwise return null.
    try{
      let re = new RegExp('\\|(' + strRe + ')\\|', 'gi');
      return re;
    }
    catch(e){
      console.log('Invalid regex created: ' + strRe);
      return null;
    }
  }
}


/*             SSResultSet.js              */
/* Authors: Martin Holmes and Joey Takeda. */
/*        University of Victoria.          */

/** This file is part of the projectEndings staticSearch
  * project.
  *
  * Free to anyone for any purpose, but
  * acknowledgement would be appreciated.
  * The code is licensed under both MPL and BSD.
  */

/** @class SSResultSet
  * @description This is the class that handles the building of the
  * search result set, and then its display, paged or not. An
  * instance of this class is instantiated by the host StaticSearch
  * class. It manages search hits using a Map(), with document ids
  * forming the keys, and values being objects based on the JSON
  * objects returned from the search index queries.
  */
class SSResultSet{
/** 
  * constructor
  * @description The constructor is typically called from the host
  *              StaticSearch instance, and it passes only the 
  *              information required by the result set object.
  * @param {number} maxKwicsToShow The maximum number of keyword-
  *              in-context strings to display for any single hit
  *              document.
  * @param {RegExp} reKwicTruncateStr A pre-constructed regular 
  *              expression that will remove leading and trailing 
  *              ellipses (whatever form these take, configured by
  *              the user) from a KWIC form before using it to create
  *              a scroll-to-text-fragment link.
  */
  
  constructor(maxKwicsToShow, reKwicTruncateStr){
    try{
      this.mapDocs = new Map([]);
      //The maximum allowed number of keyword-in-context results to be
      //included in output.
      this.maxKwicsToShow = maxKwicsToShow;
      //A regex to trim KWICs
      this.reKwicTruncateStr = reKwicTruncateStr;
      //A list of titles indexed by docUri is retrieved by AJAX
      //and set later.
      this.titles = null;
    }
    catch(e){
      console.log('ERROR: ' + e.message);
    }
  }

/**
  * @function SSResultSet~clear
  * @description Clears all content from the result map.
  * @return {boolean} true if successful, false if not.
  */
  clear(){
    try{
      this.mapDocs.clear();
      return true;
    }
    catch(e){
      console.log('ERROR: ' + e.message);
      return false;
    }
  }

/** @function SSResultSet~addArray
  * @description Adds an array of document uris to the result set. Used when
  * only facet filters are provided, so there are no hits or document scores
  * involved.
  * @param {!Array<string>} docUris The array of document URIs to add.
  * @return {boolean} true if successful; false if not.
  */
  addArray(docUris){
    try{
      for (let docUri of docUris){
        this.mapDocs.set(docUri, {docUri: docUri, score: 0, sortKey: this.getSortKeyByDocId(docUri), contexts: []});
      }
      return true;
    }
    catch(e){
      console.log('ERROR: ' + e.message);
      return false;
    }
  }

/**
  * @function SSResultSet~has
  * @description Provides access to the Map.prototype.has() function
  * to check whether a document is already in the result set.
  * @param {string} docUri The URI of the document to check, which will
  * be the key to the entry in the map.
  * @return {boolean} true if this document is in the map; false if not.
  */
  has(docUri){
    return this.mapDocs.has(docUri);
  }
/**
  * @function SSResultSet~set
  * @description Provides access to the Map.prototype.set() function
  * to add data to the result set. This first checks whether there
  * is already an entry for this docUri, and if there is, it merges the
  * data instead; otherwise, it sets the data.
  * @param {string} docUri The URI of the document to check, which will
  * be the key to the entry in the map.
  * @param {Object} data The structured data from the query index.
  * @return {boolean} true if successful, false if not.
  */
  set(docUri, data){
    try{
      if (this.mapDocs.has(docUri)){
        this.merge(docUri, data);
      }
      else{
        this.mapDocs.set(docUri, data);
//Add the sort key if there is one.
        this.mapDocs.get(docUri).sortKey = this.getSortKeyByDocId(docUri);
//Now we need to truncate the list of kwic contexts in case it's too long.
        this.mapDocs.get(docUri).contexts = this.mapDocs.get(docUri).contexts.slice(0, this.maxKwicsToShow);
      }
      return true;
    }
    catch(e){
      console.log('ERROR: ' + e.message);
      return false;
    }
  }
/**
  * @function SSResultSet~merge
  * @description Merges an incoming dataset for a document id with an
  * existing entry for that docUri. This involves two steps: first,
  * increment the score for the document, and second, add any keyword-
  * in-context strings from the new item.
  * @param {string} docUri The URI of the document to check, which will
  * be the key to the entry in the map.
  * @param {Object} data The structured data from the query index.
  * @return {boolean} true if successful, false if not.
  */
  merge(docUri, data){
    try{
      if (!this.mapDocs.has(docUri)){
        this.mapDocs.set(docUri, data);
        this.mapDocs.get(docUri).sortKey = this.getSortKeyByDocId(docUri);
      }
      else{
        let currEntry = this.mapDocs.get(docUri);
        let i = 0;
        while (i < data.contexts.length){
          if (currEntry.contexts.indexOf(data.contexts[i]) < 0){
            currEntry.contexts.push(data.contexts[i]);
            currEntry.score += data.score;
          }
          i++;
        }
      }
      return true;
    }
    catch(e){
      console.log('ERROR: ' + e.message);
      return false;
    }
  }

/**
  * @function SSResultSet~delete
  * @description Deletes an existing entry from the map.
  * @param {string} docUri The URI of the document to delete.
  * @return {boolean} true if the item existed and was successfully
  * deleted, false if not, or if there is an error.
  */
  delete(docUri){
    try{
      return this.mapDocs.delete(docUri);
    }
    catch(e){
      console.log('ERROR: ' + e.message);
      return false;
    }
  }

/**
  * @function SSResultSet~deleteArray
  * @description Deletes a collection of existing entries from the map.
  * @param {Array.<String>} arrDocUris The URIs of the document to delete.
  * @return {boolean} true if any of the items existed and was successfully
  * deleted, false if not, or if there is an error.
  */
  deleteArray(arrDocUris){
    let result = false;
    try{
      for (let i=0; i<arrDocUris.length; i++){
        let deleted = this.mapDocs.delete(arrDocUris[i]);
        result = result || deleted;
      }
      return result;
    }
    catch(e){
      console.log('ERROR: ' + e.message);
      return false;
    }
  }

  /**
   * @function SSResultSet~filterByContexts
   * @description Deletes any contexts that are not "in" a selected context
   * and deletes the document from the result set if the document is removed
   * @param activeContextIds{XSet.<String>} contextIds The context ids to use
   * @return {boolean} true if any items remain, false if not
   */
  filterByContexts(activeContextIds){
    try{
      for (let [key, value] of this.mapDocs){
        let contexts = value.contexts;
        // Filter the contexts using the intersection of the two sets
        let filteredContexts = contexts.filter(ctx => {
          if (!ctx.hasOwnProperty('in')){
            return false;
          }
          let ctxIds = ctx.in;
          let ctxSet = new XSet(ctxIds);
          let intersection = ctxSet.intersection(activeContextIds);
          return (intersection.size > 0);
        });
        // If there are no contexts left, then
        // delete the document from the result set
        if (filteredContexts.length === 0){
          this.mapDocs.delete(key);
          continue;
        }
        //Otherwise, reassign the map, copying
        // the values but overwriting the contexts
        // and the score
        
        this.mapDocs.set(key, {
          ...value,
          contexts: filteredContexts,
          score: parseInt(filteredContexts.reduce((total, b) => {
              return total + parseInt(b.weight);
           }, 0))
        });
      }
      return (this.mapDocs.size > 0);
    } catch(e){
      console.log('ERROR: ' + e.message);
      return false;
    }
  }
/**
  * @function SSResultSet~filterBySet
  * @description Deletes any entry in the list which doesn't match an item
  * in the paramter set.
  * @param {Set.<String>} acceptableDocUris The URIs of docs to retain.
  * @return {boolean} true if any items remain, false if not.
  */
  filterBySet(acceptableDocUris){
    try{
      for (let [key, value] of this.mapDocs){
        if (! acceptableDocUris.has(key)){
          this.mapDocs.delete(key);
        }
      }
      return (this.mapDocs.size > 0);
    }
    catch(e){
      console.log('ERROR: ' + e.message);
      return false;
    }
  }

/**
  * @function SSResultSet~getSize
  * @description Returns the number of items in the result set.
  * @return {number} number of documents in the result set.
  */
  getSize(){
    try{
      return this.mapDocs.size;
    }
    catch(e){
      console.log('ERROR: ' + e.message);
      return 0;
    }
  }

/**
  * @function SSResultSet~getContextCount
  * @description Returns the number of kwic contexts in the result set.
  * @return {number} number of kwic contexts in the result set.
  */
  getContextCount(){
    try{
      let arr = [];
      for (let [key, value] of this.mapDocs){
        arr.push(value.contexts.length);
      }
      return arr.reduce(function(a, b){return a + b;}, 0);
    }
    catch(e){
      console.log('ERROR: ' + e.message);
      return 0;
    }
  }

/**
  * @function SSResultSet~sortByScoreDesc
  * @description Sorts the collection of documents so that the highest
  *              scoring items come at the top.
  * @return {boolean} true if successful, false on error.
  */
  sortByScoreDesc(){
    try{
      let s = this.mapDocs.size;
      //this.mapDocs = new Map([...this.mapDocs.entries()].sort((a, b) => b[1].score - a[1].score));
      this.mapDocs = new Map([...this.mapDocs.entries()].sort(function(a, b){
        let x = b[1].score - a[1].score; 
        return (x == 0)? a[1].sortKey.localeCompare(b[1].sortKey) : x; 
      })); 
      return (s === this.mapDocs.size);
    }
    catch(e){
      console.log('ERROR: ' + e.message);
      return false;
    }
  }

/**
  * @function SSResultSet~resultsAsHtml
  * @description Outputs a ul element containing an li element for each
  *              result in the search; context strings are also included,
  *              and where a document has a defined docImage, that is also
  *              included.
  * @param {string} strScore caption for the score assigned to a hit document.
  * @return {Element} an unordered list (ul) element ready for insertion into 
  *                   the host document.
  */
  resultsAsHtml(strScore){
    let ul = document.createElement('ul');
    for (let [key, value] of this.mapDocs){
      let li = document.createElement('li');
      let d = document.createElement('div');
      let docTitle = this.getTitleByDocId(value.docUri);
      let imgPath = this.getThumbnailByDocId(value.docUri);
      //If there is a docImage, include it.
      if (imgPath.length > 0){
        let imgA = document.createElement('a');
        imgA.setAttribute('href', value.docUri);
        let img = document.createElement('img');
        img.setAttribute('alt', docTitle);
        img.setAttribute('title', docTitle);
        img.setAttribute('src', imgPath);
        imgA.appendChild(img);
        li.appendChild(imgA);
      }
      let a = document.createElement('a');
      a.setAttribute('href', value.docUri);
      let t = document.createTextNode(docTitle);
      a.appendChild(t);
      d.appendChild(a);

      if (value.score > 0){
        let scoreSpan = document.createElement('span');
        let scoreSpace = document.createTextNode(' ');
        scoreSpan.innerHTML = strScore + value.score;
        d.append(scoreSpace);
        d.appendChild(scoreSpan);
      }
      //Now process KWIC contexts if they exist.
      if (value.contexts.length > 0){
        //Sort these in document order. Suppress missing property error for compiler.
        value.contexts.sort( /** @suppress {missingProperties} */function(a, b){return a.pos - b.pos;});
        let ul2 = document.createElement('ul');
        ul2.setAttribute('class', 'kwic');
        for (let i=0; i<Math.min(value.contexts.length, this.maxKwicsToShow); i++){
          //Output the KWIC.
          let li2 = document.createElement('li');
          let sp = document.createElement('span');
          sp.innerHTML = value.contexts[i].context;
          li2.appendChild(sp);
          //Create a query string containing the marked text so that downstream JS can 
          //do its own highlighting on the target page.
          let cleanMark = value.contexts[i].context.replace(/.*<mark>([^<]+)<\/mark>.+/, '$1');
          let queryString = '?ssMark=' + encodeURIComponent(cleanMark);
          //If we have a fragment id, output that.
          if (((value.contexts[i].hasOwnProperty('fid'))&&(value.contexts[i].fid != ''))){
            let fid = value.contexts[i].hasOwnProperty('fid')? value.contexts[i].fid : '';
            let a2 = document.createElement('a');
            a2.appendChild(document.createTextNode('\u21ac'));
            a2.setAttribute('href', value.docUri + queryString + '#' + fid);
            a2.setAttribute('class', 'fidLink');
            li2.appendChild(a2);
          }
          else{
            let sp2 = document.createElement('span');
            sp2.appendChild(document.createTextNode('\u00A0'));
            li2.appendChild(sp2);
          }
          //Now look for any custom properties that have been passed through
          //from the source document's custom attributes, and if any are 
          //present, generate attributes for them.
          if (value.contexts[i].hasOwnProperty('prop')){
            let props = Object.entries(value.contexts[i].prop);
            for (const [key, value] of props){
              li2.setAttribute('data-ss-' + key, value);
              if (key == 'img'){
                let ctxImg = document.createElement('img');
                ctxImg.setAttribute('src', value);
                li2.insertBefore(ctxImg, li2.firstChild);
              }
            }
          }
          ul2.appendChild(li2);
        }
        d.appendChild(ul2);
      }
      li.appendChild(d);
      ul.appendChild(li);
    }
    return ul;
  }

/** @function SSResultSet~getTitleByDocId
  * @description this function returns the title of a document based on
  *              its id.
  * @param {string} docId the id of the document.
  * @return {string} the title, or a placeholder if not found.
  */
  getTitleByDocId(docId){
    try{
      return this.titles.get(docId)[0];
    }
    catch(e){
      return '[No title]';
    }
  }

/** @function SSResultSet~getThumbnailByDocId
  * @description this function returns a thumbnail image for a document
  *              based on its id. If no thumbnail is defined in the ssTitles
  *              JSON, it returns an empty string.
  * @param {string} docId the id of the document.
  * @return {string} the relative path to an image, or an empty string.
  */
  getThumbnailByDocId(docId){
    try{
      if (this.titles.get(docId).length > 1){
        return this.titles.get(docId)[1];
      }
      else{
        return '';
      }
    }
    catch(e){
      return '';
    }
  }

/** @function SSResultSet~getSortKeyByDocId
  * @description this function returns a pre-configured sort key for a document
  *              based on its id. If no sort key is defined in the ssTitles
  *              JSON, it returns an empty string. Sort keys are used to 
  *              sequence result sets where their scores are identical.
  * @param {string} docId the id of the document.
  * @return {string} the sort key for this document, or an empty string.
  */
  getSortKeyByDocId(docId){
    try{
      if (this.titles.get(docId).length > 2){
        return this.titles.get(docId)[2];
      }
      else{
        return '';
      }
    }
    catch(e){
      return '';
    }
  }

/**
  * @function SSResultSet~resultsAsObject
  * @description Outputs an object containing result set counts, to be
  *              used in automated testing.
  * @return {Object} an object structure containing counts of docs found,
  *                  total contexts, and total score. Totting them up in
  *                  this way doesn't mean anything in particular, but it
  *                  provides a quick way to check whether things have
  *                  changed and a test is not returning what it used to.
  */
  resultsAsObject(){
    let scoreTotal = 0;
    let contextsTotal = 0;
    for (let [key, value] of this.mapDocs){
      scoreTotal += value.score;
      contextsTotal += value.contexts.length;
    }
    return {
      docsFound: this.mapDocs.size,
      contextsFound: contextsTotal,
      scoreTotal: scoreTotal
    }
  }
}

/*                 XSet.js                 */
/* Authors: Martin Holmes and Joey Takeda. */
/*        University of Victoria.          */

/** This file is part of the projectEndings staticSearch
  * project.
  *
  * Free to anyone for any purpose, but
  * acknowledgement would be appreciated.
  * The code is licensed under both MPL and BSD.
  */
  
/** @class XSet
  * @extends Set
  * @description This class inherits from the Set class but
  * adds a single property and a convenience function for 
  * adding items directly from an array.
  */
  class XSet extends Set{
/** 
  * constructor
  * @description The constructor receives a single optional parameter
  *              which if present is used by the ancestor Set object
  *              constructor.
  * @param {Iterable=} iterable An optional Iterable object. If an 
  *              iterable object is passed, all of its elements will 
  *              be added to the new XSet.
  *              
  */
  constructor(iterable){
    super(iterable);
    this.filtersActive = false; //Used when a set is empty, to distinguish
                             //between filters-active-but-no-matches-found
                             //and no-filters-selected.
  }

/** @function XSet~addArray
  * @param {!Array} arr an array of values that are to be added.
  * @description this is a convenience function for adding a set of
  * values in a single operation.
  */
  addArray(arr){
    for (let item of arr){
      this.add(item);
    }
  }
}

/*            SSTypeAhead.js               */
/* Authors: Martin Holmes and Joey Takeda. */
/*        University of Victoria.          */

/** This file is part of the projectEndings staticSearch
  * project.
  *
  * Free to anyone for any purpose, but
  * acknowledgement would be appreciated.
  * The code is licensed under both MPL and BSD.
  */
  
/** @class SSTypeAhead
  * @description This class turns a text input control
  *              into a typeahead control that can generate
  *              label/checkbox groups for search filter 
  *              items based on a JSON dataset.
  */
  class SSTypeAhead{
/** 
  * constructor
  * @description The constructor receives two parameters, the
  *              containing element (usually a fieldset) and 
  *              the filter data that includes all the individual
  *              ids and values it needs to provide typeahead 
  *              functionality and generate label/checkbox groups
  *              from user selections.
  * @param {!Element} rootEl the wrapper element containing the 
  *              input control, and which will also contain the 
  *              generated content.
  * @param {!Object} filterData the set of filter data retrieved 
  *              as JSON by the StaticSearch instance which is 
  *              creating this control.
  * @param {!string} filterName the textual descriptive name of the 
  *              filter.* 
  * @param {!number} minNameLength the minimum length of textual input that
  *               will trigger a typeahead search. Normally equal to the 
  *               shortest length of item in the typeahead data list.
  *              
  */
  constructor(rootEl, filterData, filterName, minNameLength){
    this.rootEl = rootEl;
    this.filterData = filterData;
    this.filterName = filterName;
    this.minNameLength = minNameLength;
    this.reId = /^ssFeat\d+_\d+$/;
    //Because so much staticSearch filter handling is based on 
    //the string values of items rather than ids, we create a map
    //of values to ids.
    this.filterMap = new Map();
    for (let key of Object.keys(this.filterData)){
      if (this.reId.test(key)){
        this.filterMap.set(this.filterData[key].name, key);
      }
    };
    
    this.input = this.rootEl.getElementsByTagName('input')[0];
    this.input.addEventListener('input', this.suggest.bind(this));
    this.input.addEventListener('keydown', ss.debounce(function(e){this.keyOnInput(e);}.bind(this)), 500);
    this.input.setAttribute('autocomplete', 'off');
    this.rootEl.setAttribute('tabindex', '0');
    this.rootEl.addEventListener('keydown', function(e){this.escape(e.key);}.bind(this));
    this.menu = document.createElement('menu');
    this.rootEl.appendChild(this.menu);
    this.checkboxes = document.createElement('div');
    this.checkboxes.classList.add('ssSuggest');
    this.rootEl.appendChild(this.checkboxes);
    this.rootEl.addEventListener('click', function(e){this.blurringMenu(e);}.bind(this), true);

    //Flag to track whether we're already working.
    this.populating = false;
  }
  
  /** @function SSTypeAhead~clearSuggestions
  * @description This simply empties the drop-down suggestions menu.
  */
  clearSuggestions(){
    this.menu.innerHTML = '';
  }
  
  /** @function SSTypeAhead~escape
  * @description This is called when a key is pressed, and it simply 
                 clears the suggestions menu if the key is Escape.
  * @param {string} key the KeyboardEvent.key DOMString value for the key pressed.
  */
  escape(key){
    if (key === 'Escape'){
      this.clearSuggestions();
    }
  }
  
  /** @function SSTypeAhead~blurringMenu
  * @description This is called when the container root element is clicked.
  *              Its purpose is to clear the current suggestions menu when 
  *              the user stops interacting with the control. Along with the
  *              escape key, this gives the user a way to close the menu.
  * @param {Event} e the click event.
  */
  blurringMenu(e){
    if (e.target == e.currentTarget){
      this.clearSuggestions();
    }
  }
  
  /** @function SSTypeAhead~populate
  * @description This searches through the list of values for the control
  *              and creates a suggestion menu item for each one that 
  *              matches.
  */
  populate(){
    if ((this.populating)||(this.input.value.length < this.minNameLength)){
      return;
    }
    this.populating = true;
    try{
      let re = new RegExp(this.input.value, 'i');
      /*for (let i=2; i<Object.entries(this.filterData).length; i++){
        let id = Object.entries(this.filterData)[i][0];
        let name = Object.entries(this.filterData)[i][1].name;
        if ((name.match(re))&&(this.reId.test(id))){
          let d = document.createElement('div');
          d.setAttribute('data-val', name);
          d.setAttribute('data-id', id);
          d.classList.add('select');
          d.appendChild(document.createTextNode(name));
          d.setAttribute('tabindex', '0');
          d.addEventListener('click', function(e){this.select(e);}.bind(this));
          d.addEventListener('keydown', function(e){this.keyOnSelection(e);}.bind(this));
          this.menu.appendChild(d);
        }
      }*/
      //New approach from JT for more speed.
      // JT added new map approach
      this.filterMap.forEach((id, name) => {
        if (name.match(re) && this.reId.test(id)){
            let d = document.createElement('div');
            d.setAttribute('data-val', name);
            d.setAttribute('data-id', id);
            d.classList.add('select');
            d.appendChild(document.createTextNode(name));
            d.setAttribute('tabindex', '0');
            d.addEventListener('click', function(e){this.select(e);}.bind(this));
            d.addEventListener('keydown', function(e){this.keyOnSelection(e);}.bind(this));
            this.menu.appendChild(d); 
        }
      });
    }
    finally{
      this.populating = false;
    }
  }
  
  /** @function SSTypeAhead~suggest
  * @description This clears existing suggestions and constructs a new set.
  */  
  suggest(){
    this.clearSuggestions();
    this.populate();
  }
  
  /** @function SSTypeAhead~keyOnInput
  * @description This is called when a key is pressed on the input, and if it's
  *              the down arrow, it navigates the focus down into the suggestion
  *              list.
  * @param {Event} e the KeyboardEvent for the key pressed.
  */  
  keyOnInput(e){
    if ((e.key === 'ArrowDown')&&(this.menu.firstElementChild)){
      this.menu.firstElementChild.focus();
      e.preventDefault();
    }
  }

  /** @function SSTypeAhead~keyOnSelection
  * @description This is called when a key is pressed on the menu, and if it's
  *              the down arrow, it navigates the focus down into the suggestion
  *              list.
  * @param {Event} e the KeyboardEvent for the key pressed.
  */    
  keyOnSelection(e){
    let el = e.target;
    switch (e.key){
      case 'Enter': 
        this.select(e);
        break;
      case 'ArrowUp':
        el.previousElementSibling ? el.previousElementSibling.focus() : this.input.focus();
        break;
      case 'ArrowDown':
        el.nextElementSibling ? el.nextElementSibling.focus() : el.parentNode.firstElementChild.focus();
        break;
      default:
    }
    e.preventDefault();
  }

  /** @function SSTypeAhead~select
  * @description This creates a new checkbox + label block for 
  *              the selected item in the menu, unless there is
  *              already one there.
  * @param {Event} e the KeyboardEvent for the key pressed.
  */     
  select(e){
    let id = e.target.getAttribute('data-id');
    let val = e.target.getAttribute('data-val');
    this.addCheckbox(val);
  }
  
  /** @function SSTypeAhead~addCheckbox
  * @description This creates a new checkbox + label block for 
  *              the selected item in the menu, or based on 
  *              a call from outside unless there is already 
  *              already one there, in which case we check it.
  * @param {!string} val the text value for the checkbox.
  */  
  addCheckbox(val){
    let id = this.filterMap.get(val);
    if (!id){return;}
    //Check for an existing one:
    for (let c of this.checkboxes.querySelectorAll('input')){
      if (c.getAttribute('id') == id){
        //We just check it if it's already there.
        c.checked = true;
        return;
      }
    }
    //Don't have one yet, so add one.
    let s = document.createElement('span');
    s.setAttribute('data-val', val);
    let c = document.createElement('input');
    c.setAttribute('type', 'checkbox');
    c.setAttribute('checked', 'checked');
    c.setAttribute('title', this.filterName);
    c.setAttribute('value', val);
    c.setAttribute('class', 'staticSearch_feat');
    c.setAttribute('id', id);
    s.appendChild(c);
    let l = document.createElement('label');
    l.setAttribute('for', id);
    l.appendChild(document.createTextNode(val));
    s.appendChild(l);
    let b = document.createElement('button');
    b.appendChild(document.createTextNode('\u2718'));
    b.addEventListener('click', function(e){this.removeCheckbox(e);}.bind(this));
    s.appendChild(b);
    this.checkboxes.appendChild(s);
  }
  
  /** @function SSTypeAhead~setCheckboxes
  * @description This is provided with an Array of value strings,
  *              and for each one, it either creates a new checkbox
  *              or checks an existing one; then checkboxes not 
  *              included in the array are unchecked. This allows the
  *              external caller to set the entire status of the control
  *              based e.g. on a URL query string.
  * @param {!Array} arrVals the Array of string values.
  */  
  setCheckboxes(arrVals){
  //First uncheck any existing items which aren't in the list.
    for (let c of this.checkboxes.querySelectorAll('input')){
      if (arrVals.indexOf(c.getAttribute('value')) < 0){
        c.checked = false;
      }
    }
  //Now create any new ones we need.
    for (let val of arrVals){
      this.addCheckbox(val);
    }
  }
  
  /** @function SSTypeAhead~removeCheckbox
  * @description This is called by e.g. a click on the little
  *              button that each checkbox block has, enabling
  *              its removal if the user doesn't want it any more.
  * @param {Event} e the event that triggers the removal.
  */   
  removeCheckbox(e){
    e.target.parentNode.parentNode.removeChild(e.target.parentNode);
  }
}
/*           ssStemmer.js             */
/* Authors: Martin Holmes and Joey Takeda. */
/*        University of Victoria.          */

/* This file is an implementation of the
 * Porter2 stemmer as described  here:
 *
 * https://snowballstem.org/algorithms/english/stemmer.html
 *
 * It is part of the projectEndings staticSearch
 * project.
 *
 * Free to anyone for any purpose, but
 * acknowledgement would be appreciated. */

 /** HOW TO USE:
     var ssStemmer = new SSStemmer();
     var stemmedToken = ssStemmer.stem(token);
  */

 /** WARNING:
   * This lib has "use strict" defined. You may
   * need to remove that if you are mixing this
   * code with non-strict JavaScript.   
   */

/*  We use a class to put everything in our
 *  SSStemmer 'namespace' (= staticSearch Stemmer). */

class SSStemmer{
  constructor(){
    // A character class of vowels
      this.vowel                         = '[aeiouy]';
      this.reVowel                       = new RegExp(this.vowel);
    //A character class of non-vowels
      this.nonVowel                      = '[^aeiouy]';
      this.reNonVowel                    = new RegExp(this.nonVowel);
    // A regex for determining whether a token ends with a short syllable
      this.reEndsWithShortSyllable       = new RegExp(this.nonVowel + this.vowel + '[^aeiouywxY]$');
    // A regex for doubled consonants
      this.dbl                           = '((bb)|(dd)|(ff)|(gg)|(mm)|(nn)|(pp)|(rr)|(tt))';
      this.reDbl                         = new RegExp(this.reDbl);
    // A regular expression which returns R1, defined as "the region after
    // the first non-vowel following a vowel, or the end of the word if
    // there is no such non-vowel".
    //See exceptional cases below. It also returns R2 when applied to R1.
      this.reR1R2                        = new RegExp('^.*?' + this.vowel + this.nonVowel + '(.*)$');
    // A regular expression which for the exceptions: "If the words begins gener,
    // commun or arsen, set R1  to be the remainder of the word."
      this.reR1Except                    = /^(gener|commun|arsen)(.*)$/;
    // arrStep2Seq is an array of items, each of which is a three-item
    // array consisting of a suffix to match, a suffix to replace (which
    // may be the same, or may be shorter) and a replacement string.
    // NOTE: When browser support for lookbehinds is available, this
    // can be simplified.
      this.arrStep2Seq = [
                    [/ousness$/, /ousness$/, 'ous'],
                    [/iveness$/, /iveness$/, 'ive'],
                    [/fulness$/, /fulness$/, 'ful'],
                    [/ization$/, /ization$/, 'ize'],
                    [/ational$/, /ational$/, 'ate'],
                    [/biliti$/, /biliti$/, 'ble'],
                    [/tional$/, /tional$/, 'tion'],
                    [/lessli$/, /lessli$/, 'less'],
                    [/ousli$/, /ousli$/, 'ous'],
                    [/fulli$/, /fulli$/, 'ful'],
                    [/iviti$/, /iviti$/, 'ive'],
                    [/entli$/, /entli$/, 'ent'],
                    [/alism$/, /alism$/, 'al'],
                    [/aliti$/, /aliti$/, 'al'],
                    [/enci$/, /enci$/, 'ence'],
                    [/anci$/, /anci$/, 'ance'],
                    [/abli$/, /abli$/, 'able'],
                    [/izer$/, /izer$/, 'ize'],
                    [/ation$/, /ation$/, 'ate'],
                    [/ator$/, /ator$/, 'ate'],
                    [/alli$/, /alli$/, 'al'],
                    [/bli$/, /bli$/, 'ble'],
                    [/logi$/, /ogi$/, 'og'],
                    [/[cdeghkmnrt]li$/, /li$/,  '']
                    ];
    // step3Seqis a list of suffixes to
    // be evaluated against a token; as soon as one is matched, the rest
    // are ignored, and if the match location is in R1 (or in R2 for
    // -ative, a replacement operation is done.
    // The format is:
    //   whichR, match, replacement
    // where whichR is either 1 or 2.
    // So for example: "ative" matches, but the match must be in R2 to
    // satisfy the condition.
      this.arrStep3Seq = [
                      [1, /ational$/, 'ate'],
                      [1, /tional$/, 'tion'],
                      [1, /alize$/, 'al'],
                      [1, /icate$/, 'ic'],
                      [1, /iciti$/, 'ic'],
                      [2, /ative$/, ''],
                      [1, /ical$/, 'ic'],
                      [1, /ness$/, ''],
                      [1, /ful$/, '']
                    ];
    // arrStep4Seq is a list of suffixes to
    // be evaluated against a token; as soon as one is matched,
    // the rest are ignored, and if the match location is in R2,
    // a delete operation is done.
    // The format is:
    //  match, delete
    // So for example: "al" matches, but the match must be in R2
    // to satisfy the condition.
      this.arrStep4Seq = [
                      [/ement$/, /ement$/],
                      [/ment$/, /ment$/],
                      [/ance$/, /ance$/],
                      [/ence$/, /ence$/],
                      [/able$/, /able$/],
                      [/ible$/, /ible$/],
                      [/[st]ion$/, /ion$/],
                      [/ant$/, /ant$/],
                      [/ent$/, /ent$/],
                      [/ism$/, /ism$/],
                      [/ate$/, /ate$/],
                      [/iti$/, /iti$/],
                      [/ous$/, /ous$/],
                      [/ive$/, /ive$/],
                      [/ize$/, /ize$/],
                      [/al$/, /al$/],
                      [/er$/, /er$/],
                      [/ic$/, /ic$/]
                    ];
    // arrExeptions is a list of exceptional forms and their matching
    // stems, to be processed before the rest of the stemming takes place.
    // The format is:
    //     token:stem
    // This list includes items from two lists in the Porter2 description:
    // the set of special words which have hard-coded stems, and the set
    // of words which should remain unchanged.
      this.arrExceptions = [
                        'skis',
                        'skies',
                        'dying',
                        'lying',
                        'tying',
                        'idly',
                        'gently',
                        'ugly',
                        'early',
                        'only',
                        'singly',
                        'sky',
                        'news',
                        'howe',
                        'atlas',
                        'cosmos',
                        'bias',
                        'andes'
                      ];

      this.arrExceptionStems=[
                        'ski',
                        'sky',
                        'die',
                        'lie',
                        'tie',
                        'idl',
                        'gentl',
                        'ugli',
                        'earli',
                        'onli',
                        'singl',
                        'sky',
                        'news',
                        'howe',
                        'atlas',
                        'cosmos',
                        'bias',
                        'andes'
                      ];
    // arrStep1aExceptions is a short list of items to be left unchanged
    // if they are found after step 1a.
      this.arrStep1aExceptions = [
                              'inning', 'outing', 'canning', 'herring',
                              'earring', 'proceed', 'exceed', 'succeed'
                            ];
  }
  /**
   * stem is the core function that takes a single token and returns
   * its stemmed version.
   * @param  {string} token The input token
   * @return {string}       the stemmed token
   */
   stem(token){
    let normToken = token.normalize('NFC');
     if (normToken.length < 3){
       return normToken;
     }
     else{
       var indEx = this.arrExceptions.indexOf(normToken);
       if (indEx > -1){
         return this.arrExceptionStems[indEx];
       }
       else{
         var pref = this.preflight(normToken);
         var R = this.getR1AndR2(pref);
         var s0 = this.step0(pref);
         var s1 = this.step1(s0, R.r1of);
         if (this.arrStep1aExceptions.indexOf(s1) > -1){
           return s1;
         }
         else{
           var s2 = this.step2(s1, R.r1of);
           var s3 = this.step3(s2, R.r1of, R.r2of);
           var s4 = this.step4(s3, R.r2of);
           var s5 = this.step5(s4, R.r1of, R.r2of);
           return s5;
         }
       }
     }
   }

  /**
   * getR1AndR2 decomposes an input token to get the R1 and R2 regions,
   * and returns the string values of those two regions, along with their
   * offsets.
   * @param  {string} token The input token
   * @return {Object}       an object with four members:
   *                        r1 {string} the part of the word constituting R1
   *                        r1 {string} the part of the word constituting R2
   *                        r1of {Number} the offset of the start of R1
   *                        r2of {Number} the offset of the start of R2
   */
   getR1AndR2(token){
     var R1 = '';
     if (token.match(this.reR1Except)){
       R1 = token.replace(this.reR1Except, '$2');
     }
     else{
       if (token.match(this.reR1R2)){
         R1 = token.replace(this.reR1R2, '$1');
       }
     }
     var R1Index = (token.length - R1.length) + 1;
     var R2Candidate = R1.replace(this.reR1R2, '$1');
     var R2 = (R2Candidate == R1)? '' : R2Candidate;
     var R2Index = (R2Candidate == R1)? token.length + 1 : (token.length - R2.length) + 1;
     return {r1: R1, r2: R2, r1of: R1Index, r2of: R2Index};
   }

   /**
     * wordIsShort returns a boolean value from testing the input word
     * against a regular expression to determine whether it matches the
     * Porter2 definition of a short word. A short syllable is "either
     * (a) a vowel followed by a non-vowel other than w, x or Y and
     * preceded by a non-vowel, or * (b) a vowel at the beginning of the
     * word followed by a non-vowel," and "a word is called short if it
     * ends in a short syllable, and if R1 is null." R1 being null
     * basically means the R1 region is empty; that means it starts
     * after the end of the word, so its offset is the word-length + 1.
     * @param  {string} token the input token
     * @param  {Number} r1of  the offset of the R1 region
     * @return {boolean}      true if word is short, otherwise false.
     */
     wordIsShort(token, r1of){
       var R1IsNull = (token.length < r1of);
       var reOnlyShortSyllable = new RegExp('^' + this.vowel +
                                            this.nonVowel +
                                            this.nonVowel + '*$');
       return Boolean(((token.match(this.reEndsWithShortSyllable))||
              ((token.match(reOnlyShortSyllable)))) && (R1IsNull));
     }

  /**
    * preflight does a couple of simple replacements that need to precede
    * the actual stemming process.
    * @param  {string} token the input token
    * @return {string}       the result of the replacement operations
    */
  preflight(token){
    return token.replace(/^'/, '').replace(/^y/, 'Y').replace(new RegExp('(' + this.vowel + ')y'), '$1Y');
  }

  /**
    * step0 trims plural/possessive type suffixes from the end.
    * @param  {string} token the input token
    * @return {string}       the result of the trimming operations
    */
  step0(token){
    return token.replace(/'(s(')?)?$/, '');
  }

 /**
   * step1 performs three replacements on the end of a token (1a, 1b and 1c).
   * @param  {string} token the input token
   * @param  {Number} R1    the offset of the R1 region in the token
   * @return {string}       the result of the replacement operations
   */
   step1(token, R1){
     //Some regular expressions used only in this function.
     var reStep1a2     = /(..)((ied)|(ies))$/;
     var reStep1a3     = /((ied)|(ies))$/;
     var reStep1a4     = new RegExp('(.*' + this.vowel + '.+)s$');
     var reStep1a5     = /((us)|(ss))$/;
     var reStep1b1     = /eed(ly)?$/;
     var reStep1b2     = new RegExp('(' + this.vowel + '.*)((ed)|(ing))(ly)?$');
     var reStep1b3     = /((at)|(bl)|(iz))$/;
     var reStep1c      = new RegExp('(.+' + this.nonVowel + ')[Yy]$');

     //Start step 1a
     //Default if step1a matches don't pan out.
     var step1a = token;

     if (token.match(/sses$/)){
       step1a = token.replace(/sses$/, 'ss');
     }
     else{
       if (token.match(reStep1a2)){
         step1a = token.replace(reStep1a3, 'i');
       }
       else{
         if (token.match(reStep1a3)){
           step1a = token.replace(reStep1a3, 'ie');
         }
         else{
           if ( (token.match(reStep1a4)) && (! token.match(reStep1a5)) ){
             step1a = token.replace(reStep1a4, '$1');
           }
         }
       }
     }

     //Start step 1b
     //Default.
     var step1b = step1a;
     //If it's one of the exceptions, nothing more to do.
     if (this.arrStep1aExceptions.indexOf(step1a) > -1){
       step1b = step1a;
     }
     else{
       if (step1a.match(reStep1b1)){
         var tmp1 = step1a.replace(reStep1b1, 'ee');
         if ((tmp1.length + 1) >= R1){
           step1b = tmp1;
         }
         else{
           step1b = step1a;
         }
       }
       else{
         if (step1a.match(reStep1b2)){
          var tmp2 = step1a.replace(reStep1b2, '$1');
           if (tmp2.match(reStep1b3)){
             step1b = tmp2 + 'e';
           }
           else{
             if (tmp2.match(new RegExp(this.dbl + '$'))){
               step1b = tmp2.replace(/.$/, '');
             }
             else{
               if (this.wordIsShort(tmp2, R1)){
                 step1b = tmp2 + 'e';
               }
               else{
                 step1b = tmp2;
               }
             }
           }
         }
       }
     }
     //Start step 1c
     if (step1b.match(reStep1c)){
       return step1b.replace(reStep1c, '$1i');
     }
     else{
       return step1b;
     }
   }

   /**
     * step2 consists of a sequence of items to be evaluated against the
     * input token; if a match occurs, then a) a replacement operation
     * is done ONLY IF the match is in R1, and b) the process exits
     * whether or not a replacement was done.
     * @param  {string} token the input token
     * @param  {Number} R1    the offset of the R1 region in the token
     * @return {string}       the result of the replacement operations
     */
   step2(token, R1){
     //Default return if nothing happens.
     var result = token;
     for (var i=0; i<this.arrStep2Seq.length; i++){
       if (token.match(this.arrStep2Seq[i][0])){
         var nuked = token.replace(this.arrStep2Seq[i][1], '');
         if (nuked != token){
           if ((nuked.length + 1) >= R1){
             result = token.replace(this.arrStep2Seq[i][1], this.arrStep2Seq[i][2]);
           }
           break;
         }
       }
     }
     return result;
   }

   /**
     * step3 consists of a sequence of items to be evaluated against the
     * input token; if a match occurs, then a) a replacement operation
     * is done ONLY IF the match is in a specified region, and b) the
     * process exits whether or not a replacement was done.
     * @param  {string} token the input token
     * @param  {Number} R1    the offset of the R1 region in the token
     * @param  {Number} R2    the offset of the R2 region in the token
     * @return {string}       the result of the replacement operations
     */
   step3(token, R1, R2){
     //Default return if nothing happens.
     var result = token;
     for (var i=0; i<this.arrStep3Seq.length; i++){
       var offset = (this.arrStep3Seq[i][0] == 2)? R2 : R1;
       var nuked = token.replace(this.arrStep3Seq[i][1], '');
       if (nuked != token){
         if ((nuked.length + 1) >= offset){
           result = token.replace(this.arrStep3Seq[i][1], this.arrStep3Seq[i][2]);
         }
         break;
       }
     }
     return result;
   }

   /**
     * step4 consists of a sequence of items to be evaluated against the
     * input token; if a match occurs, then a) a deletion operation is
     * done ONLY IF the match is in R2, and b) the process exits whether
     * or not a replacement was done.
     * @param  {string} token the input token
     * @param  {Number} R2    the offset of the R1 region in the token
     * @return {string}       the result of the replacement operations
     */
   step4(token, R2){
     var result = token;
     for (var i=0; i<this.arrStep4Seq.length; i++){
       var nuked = token.replace(this.arrStep4Seq[i][0], '');
       if (nuked != token){
         nuked = token.replace(this.arrStep4Seq[i][1], '')
         if ((nuked.length + 1) >= R2){
           result = nuked;
         }
         break;
       }
     }
     return result;
   }
   /**
     * step5 consists of two specific replacements which are context-dependent:
     * "Search for the the following suffixes, and, if found,
     * perform the action indicated.
     *    e delete if in R2, or in R1 and not preceded by a short syllable*
     *    l delete if in R2 and preceded by l"
     * "Finally, turn any remaining Y letters in the word back into lower case. "
     *   *On mailing list, MP confirms that this means _immediately_
     * preceded by a short syllable.
     * @param  {string} token the input token
     * @param  {Number} R1    the offset of the R1 region in the token
     * @param  {Number} R2    the offset of the R1 region in the token
     * @return {string}       the result of the replacement operations
     */
   step5(token, R1, R2){
     //Some regexps used only in this function.
     //var reStep5a = new RegExp('(^' + this.vowel + this.nonVowel +
    //                           '$)|(' + this.reEndsWithShortSyllable + ')');
    var reStep5a = /(^[aeiouy][^aeiouy]$)|([^aeiouy][aeiouy][^aeiouywxY]$)/;

     //Start step5a
     var step5a = token;
     if (token.match(/e$/)){
       var nuked = token.replace(/e$/, '');
       if ((nuked.length + 1) >= R2){
         step5a = nuked;
       }
       else{
         if (((nuked.length + 1) >= R1) && (!nuked.match(reStep5a))){
//console.log(nuked);
           step5a = nuked;
         }
       }
     }

     //Start step5b.
     var step5b = step5a;
     //Only do anything if the previous step has not changed the token.
     if (step5b == token){
       if (step5b.match(/ll$/)){
         var nuked = step5b.replace(/l$/, '');
         if ((nuked.length + 2) > R2){
           step5b = nuked;
         }
       }
     }
     return step5b.replace(/Y/g, 'y');
   }



}
