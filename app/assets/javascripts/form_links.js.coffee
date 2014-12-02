# handleMethod: function(link) {
#       var href = rails.href(link),
#         method = link.data('method'),
#         target = link.attr('target'),
#         csrfToken = $('meta[name=csrf-token]').attr('content'),
#         csrfParam = $('meta[name=csrf-param]').attr('content'),
#         form = $('<form method="post" action="' + href + '"></form>'),
#         metadataInput = '<input name="_method" value="' + method + '" type="hidden" />';

#       if (csrfParam !== undefined && csrfToken !== undefined) {
#         metadataInput += '<input name="' + csrfParam + '" value="' + csrfToken + '" type="hidden" />';
#       }

#       if (target) { form.attr('target', target); }

#       form.hide().append(metadataInput).appendTo('body');
#       form.submit();
#     },

$ = jQuery

###
A lot of this is inspired... well taken, from rails-jquery.
###
handleMethod = (link,method,newhref) ->
  href = newhref || link.attr('href')
  target = link.attr('target')
  # csrf is not used for now
  csrfToken = $('meta[name=csrf-token]').attr('content')
  csrfParam = $('meta[name=csrf-param]').attr('content')
  form = $('<form method="post" action="' + href + '"></form>')
  metadataInput = '<input name="_method" value="' + method + '" type="hidden" />'

  if csrfParam != undefined && csrfToken != undefined
    metadataInput += '<input name="' + csrfParam + '" value="' + csrfToken + '" type="hidden" />';

  form.attr('target', target) if target

  form.hide().append(metadataInput).appendTo('body')
  form.submit()


 # $document.delegate(rails.linkClickSelector, 'click.rails', function(e) {
 #      var link = $(this), method = link.data('method'), data = link.data('params'), metaClick = e.metaKey || e.ctrlKey;
 #      if (!rails.allowAction(link)) return rails.stopEverything(e);

 #      if (!metaClick && link.is(rails.linkDisableSelector)) rails.disableElement(link);

 #      if (link.data('remote') !== undefined) {
 #        if (metaClick && (!method || method === 'GET') && !data) { return true; }

 #        var handleRemote = rails.handleRemote(link);
 #        // response from rails.handleRemote() will either be false or a deferred object promise.
 #        if (handleRemote === false) {
 #          rails.enableElement(link);
 #        } else {
 #          handleRemote.error( function() { rails.enableElement(link); } );
 #        }
 #        return false;

 #      } else if (method) {
 #        rails.handleMethod(link);
 #        return false;
 #      }
 #    });

# allowAction: function(element) {
#       var message = element.data('confirm'),
#           answer = false, callback;
#       if (!message) { return true; }

#       if (rails.fire(element, 'confirm')) {
#         answer = rails.confirm(message);
#         callback = rails.fire(element, 'confirm:complete', [answer]);
#       }
#       return answer && callback;
#     },



$(document).on 'click.delete',"a[href$='\/delete']", (e)->
  # allow a new tab to be created with the link
  metaClick = e.metaKey || e.ctrlKey
  return true if metaClick

  e.preventDefault();
  link = $(this)
  method = 'delete'
  confirm_message = link.data('confirm') || 'Are you sure?'

  answer = confirm(confirm_message)

  return false unless answer

  handleMethod link, method, link.attr('href').replace(/\/delete$/,'')

