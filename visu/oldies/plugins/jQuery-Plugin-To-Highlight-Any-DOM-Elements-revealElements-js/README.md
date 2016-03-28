revealElements.js
=================

A little jQuery plugin for out of dom elements find in 'lib/' folder

In folder 'base/' you can see the main idea of this little project,
that I have translated into jQuery plugin.

> Demo : http://jp.cartoux.net/dev/revealElements.js-master/othersample.html

Usage
=====

Basic for show all dom elements with reveal class

```javascript
$.revealElements();
```
  
More specific, you can choose class of element you want to "reveal", specify the wrapper element, the overlay z-index (auto adjuste the others elements z-index) & overlay color

```javascript
$.revealElements({
	revealClass: '.reveal',
	wrapperEl: 'body',
	overlayIndex: 8,
	overlayColor: '#000'
});
```

Sample
======

Look index.html & othersample.html ! 
