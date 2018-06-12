#!/usr/bin/env node

/*
 * Very simple script that converts faust-web's sceneLineMapping to XML.
 *
 * Usage:
 *      npm install json2xml
 *      ./scl2xml.js ../faust-web/data/scene_line_mapping.js scenes.xml
 */

var fs = require('fs'),
    vm = require('vm'),
    json2xml = require('json2xml'),

    infile = process.argv[2],
    outfile = process.argv[3];

vm.runInThisContext(fs.readFileSync(infile, null, { encoding: "utf8" }));
sceneLineMapping.forEach(function(el, idx, arr) { 
    // json2xml just concatenates array elements
    arr[idx] = { scene: el, attr: { n: el.id } };  
});
fs.writeFileSync(outfile,
                 json2xml({sceneLineMapping: sceneLineMapping,
                          attr: { xmlns: "http://www.faustedition.net/ns" }},
                          { attributes_key: 'attr' }),
                 { encoding: "utf8" });
