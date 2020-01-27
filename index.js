// import hljs from "highlight.js/lib/highlight";
// import "highlight.js/styles/github.css";
// import elm from 'highlight.js/lib/languages/elm';
// hljs.registerLanguage('elm', elm);
// window.hljs = hljs;
//setTimeout(function() {hljs.initHighlighting();}, 50);

const { Elm } = require("./src/Main.elm");
const pagesInit = require("elm-pages");

pagesInit({
  mainElmModule: Elm.Main
});
