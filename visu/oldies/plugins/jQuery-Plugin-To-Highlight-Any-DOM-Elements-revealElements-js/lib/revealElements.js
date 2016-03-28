/*
	revealElements plugins works with jQuery
	by aZerato
 */
(function($) {
	
	/*
		Plugin declaration
	 */
	$.revealElements = function(options) {
		var defaults = {
			revealClass: '.reveal',
			wrapperEl: 'body',
			overlayIndex: 8,
			overlayColor: '#000'
		};

		var plugin = this;

		/*
			publics
		 */
		plugin.init = function() {
			// merge between defaults & options
			plugin.settings = $.extend({}, defaults, options);
			
			plugin.start();
		};

		plugin.start = function() {
			// array of el or only one
			// get size position of wrapperEl
			var wel = $(plugin.settings.wrapperEl),
				el = wel.find(plugin.settings.revealClass),
				welP = wel.position(),
				welW = wel.width(),
				welH = wel.height(),
				over = wel.find('.revealOverlay');
			// check if an overlay for this wrapperEl already exist
			if(over.length === 0){
				if(el.length > 1) {
					for (var i = 0; i < el.length; i++) {
						revealElement( $(el[i]) );
					};
				}
				else 
				{
					revealElement(el);
				}

				// On overlay element data annotations with wrapper element & class use for reveal are use
				$(wel).append('<div class="revealOverlay" data-revealwrapper="'+ plugin.settings.wrapperEl +'" data-revealclass="'+ plugin.settings.revealClass +'" style="top:'+ welP.top +'px; left:'+ welP.left +'px; width:'+ welW +'px; height:'+ welH +'px; background-color: '+ plugin.settings.overlayColor +'; opacity: 0.8; position: absolute; z-index: '+ plugin.settings.overlayIndex +'"></div>');
				
				canRemoveOverlay();
			}
			else 
			{
				removeReveal(over);
			}
		};

		/*
			privates
		 */
		var revealElement = function(el) {
			// get previous attr style value if exist for no remove it if delete style added with plugin 
			var	p = el.position(),
				w = el.width(),
				h = el.height(),
				prevStyle = el.attr('style');
			
			// adjust style
			p.top += 10;
			p.left -= 5;
			w += 10;
			h += 10;

			// if a style is previously setted don't erase it
			if (!prevStyle) {
				prevStyle = ''; 
			} else {
				el.attr('data-prevstyle', prevStyle);
			}

			el.addClass('revealElement');
			el.attr('style', 'position: relative; z-index: ' + plugin.settings.overlayIndex + 2 + ' !important; ' + prevStyle);

			$(plugin.settings.wrapperEl).append('<div class="revealOn" style="top:'+ p.top +'px; left:'+ p.left +'px; width:'+ w +'px; height:'+ h +'px; position: absolute; z-index: ' + plugin.settings.overlayIndex + 1 +'; background-color: rgba(255, 255, 255, 0.9); border: 1px solid rgba(0, 0, 0, 0.5); border-radius: 4px; box-shadow: 0 2px 15px rgba(0, 0, 0, 0.4);"></div>');
		}

		var canRemoveOverlay = function() {
			$('.revealOverlay').click(function() { 
				removeReveal($(this));
			});
		};

		var removeReveal = function(overlayEl) {
			// 
			var revealWrapper = overlayEl.data('revealwrapper'),
				revealClass = overlayEl.data('revealclass'),
				elWrapper = overlayEl.closest(revealWrapper),
				el = elWrapper.find(revealClass);
			
			el.removeClass('revealElement');

			// Remove all plugin modifications on dom elements
			for (var i = 0; i < el.length; i++) {
				var elCur = $(el[i]);
				elCur.removeAttr('style', '');
				if(elCur.data('prevstyle')) {
					elCur.attr('style', elCur.data('prevstyle'));
					elCur.removeAttr('data-prevstyle');
				}
			};
			
			elWrapper.find('.revealOverlay').remove();
			elWrapper.find('.revealOn').remove();
		}

		/*
			initialize
		 */
		plugin.init();
	};

	// Add to jquery functions library
	$.fn.revealElements = function(options) {
		return this.each(function() {
			if (undefined == $(this).data('revealElements')) {
				var plugin = new $.revealElements(this, options);
				$(this).data('revealElements', plugin);
			}
		});
	}
})(jQuery);