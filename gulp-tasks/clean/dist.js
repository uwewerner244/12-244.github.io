/*!
 * Project:     cv
 * File:        ./gulp-tasks/clean/dist.js
 * Copyright(c) 2016-nowdays Baltrushaitis Tomas <tbaltrushaitis@gmail.com>
 * License:     MIT
 */

'use strict';

//  ------------------------------------------------------------------------  //
//  -----------------------------  DEPENDENCIES  ---------------------------  //
//  ------------------------------------------------------------------------  //

const path = require('path');
const utin = require('util').inspect;

const del    = require('del');
const vPaths = require('vinyl-paths');

//  ------------------------------------------------------------------------  //
//  ----------------------------  CONFIGURATION  ---------------------------  //
//  ------------------------------------------------------------------------  //

let ME = Object.assign({}, global.ME || {});
utin.defaultOptions = Object.assign({}, ME.pkg.options.iopts || {});

const modName = path.basename(module.filename, '.js');
const modPath = path.relative(ME.WD, path.dirname(module.filename));

ME.Config = Object.assign({}, ME.Config || {});

let C = ME.Config.colors;
let L = `\n${C.White}${(new Array(80).join('-'))}${C.NC}\n`;

//  ------------------------------------------------------------------------  //
//  --------------------------------  EXPOSE  ------------------------------  //
//  ------------------------------------------------------------------------  //

module.exports = function (gulp) {
  console.log(`${L}[${new Date().toISOString()}][${C.Yellow}${modPath}/${modName}${C.NC}]`);

  return gulp.src([ME.DIST])
            .pipe(vPaths(del));
};
