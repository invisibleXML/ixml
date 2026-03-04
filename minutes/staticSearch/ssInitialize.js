/**
 * @preserve
 *               ssInitialize.js              
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
 * 
 * This file creates the global Sch variable and 
 * assigns an instance of the StaticSearch object to it.
 * This is the initialization process for the search 
 * page functionality. You may want to replace or remove
 * this file after the build process if you want to have
 * more control over how the object is initialized.
*/

"use strict";

var Sch;
window.addEventListener('load', function(){Sch = new StaticSearch();});