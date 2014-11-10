/*
* jQuery Live-Ready Plugin 1.0
* 
* Copyright 2010 Lars Corneliussen
* 
* Licensed under the Apache License, Version 2.0; you may not use this file except in compliance with the License.
* http://www.apache.org/licenses/LICENSE-2.0
* 
* Source: https://bitbucket.org/larscorneliussen/jquery.glossary/
* Version: 1.0
* 
* Helps with lazy initialization of certain elements. This is especially useful, when dynamically adding
* html to the page.
* 
* Examples
*   1) Run a function on document ready, and afterwards on added elements.
*
*      $.liveReady(function() {
*          // will be called with this == $(document) on ready
*          // and then on new elements, when method 'liveReady' is invoked
*      }
*      
*      $('<p></p>').liveReady(); // will call the registered function, where this is the new p-Element (jqueryfied).
*      
*   2) Run a function on all selected elements, and afterwards selected elements
*      within the scope of added elements.
*
*      $.liveReady('p.yellow', function() {
*          // will be called with this == $(document) on ready
*          // and then on new elements, when method 'liveReady' is invoked
*      }
*      $('<p class="yellow"></p>').liveReady(); // runs the registered function once
*      $('<div><p class="yellow">A</p><p class="yellow">B</p></div>').liveReady(); // runs the function twice
*/
(function ($) {

    // List of all registered functions
    var registrations = new Array();

    // Object structure for selector and method. 
    function pair(selector, method) { this.selector = selector; this.method = method; }

    $.liveReady = function (selectorOrMethod, method) {

        if (method) {
            // remember for later use
            registrations.push(new pair(selectorOrMethod, method));

            // onready: call on each occurance
            $(function () {
                $(selectorOrMethod).each(function () {
                    $.proxy(method, $(this))();
                });
            });
        } else {
            // remember for later use
            registrations.push(new pair(null, selectorOrMethod));

            // onready: call on document
            $($.proxy(selectorOrMethod, $(document)));
        }
    }

    $.fn.liveReady = function () {
        return this.each(function () {
            // the element, liveReady was called on
            var $element = $(this);

            $.each(registrations, function () {
                if (this.selector) {
                    // the element itself, if it matches the selector + all decendants, that match the selector
                    var $matching = $element.filter(this.selector).add($element.find(this.selector));

                    var method = this.method;

                    // call the registered method on each of the matched elements
                    $matching.each(function () {
                        $.proxy(method, $(this))($(this));
                    });
                } else {
                    // call on the added element itself
                    $.proxy(this.method, $element)($element);
                }
            });
        });
    };

})(jQuery);
