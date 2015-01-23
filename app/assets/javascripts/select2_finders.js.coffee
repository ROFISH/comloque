$ ->
  $(".user-finder").select2
    placeholder: "Search for a user"
    minimumInputLength: 2
    multiple:true
    ajax:
      url: "/admin/users/search.json"
      dataType: 'json'
      quietMillis: 250
      data: (term, page, context) ->
        q: term
        page: page
      results: (data, page)->
        # // since we are using custom formatting functions we do not need to alter remote JSON data
        # //return {results: data.movies};
        # //console.log(data);
        results = []
        $.each data.results,(i,x)->
          results.push({id:x[0],text:x[1]})
        # //console.log((data.results.length != 10))
        return {results:results,more:(data.results.length == 10)}
    initSelection: (element,callback) ->
      #alert('sup');
      console.log(element)
      data = [];
      val = element.val();
      if val && val != ""
        callback(JSON.parse(element.val()))
