current_template_url = null

$(document).on 'click', 'a[data-edit-kind]', (e)->
  e.preventDefault()
  $.ajax
    url: $(this).attr('href')+'.json'
    type: 'GET'
    dataType: 'json'
    # beforeSend: =>
    #   $(thethis).removeClass('draggable').removeClass('clickable')
    #   $(thethis).addClass('uploading').append(upload_bar)
    success: (data,textStatus,xhr)=>
      current_template_url = $(this).attr('href')+'.json'
      $(".theme_editor_div").show()
      $('#nothing_selected').hide()
      # alert data
      #console.log data
      if $(this).data('edit-kind') == 'template'
        window.editor.getSession().setValue(data['source'])
        window.editor.getSession().setMode("ace/mode/liquid");
        $(".theme_editor_div h4").text(data['name']+'.liquid')
      else if $(this).data('edit-kind') == 'asset'
        window.editor.getSession().setValue(data['source'])
        if data['key'].match(/\.css$/)
          window.editor.getSession().setMode("ace/mode/css");
        else if data['key'].match(/\.js$/)
          window.editor.getSession().setMode("ace/mode/javascript");
        else
          window.editor.getSession().setMode(null);
        $(".theme_editor_div h4").text(data['key'])
    error: (xhr,textStatus,errorThrown)->
      console.log("Error")
      console.log(xhr)
      console.log(textStatus)
      console.log(errorThrown)
      alert("ERROR: #{errorThrown}")

submit_template_edit = ->
  $.ajax
    url: current_template_url
    type: 'PATCH'
    # fuck it, why not both, solves the problem easier
    data: {template:{source:window.editor.getSession().getValue()},asset:{source:window.editor.getSession().getValue()}},
    dataType: 'text'
    # beforeSend: (xhr, settings) ->
    #   xhr.setRequestHeader('accept', '*/*;q=0.5, ')
    success: (data,textStatus,xhr)=>
      $('#success').fadeIn()# ->
      setTimeout ->
        $('#success').fadeOut()
      ,2000
    error: (xhr,textStatus,errorThrown)->
      console.log("Error")
      console.log(xhr)
      console.log(textStatus)
      console.log(errorThrown)
      alert("ERROR: #{errorThrown}")

$(document).on 'submit', '#theme_editor_form', (e)->
  e.preventDefault()
  if current_template_url
    submit_template_edit()
