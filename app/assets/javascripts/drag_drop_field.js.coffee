# alert('sup')

# A dragover event on the document is required to enable the drag/drop in the first place
$(document).on 'dragover', (e)->
  e.preventDefault && e.preventDefault()
  return

#just in case one accidentally drops elsewhere, it doesn't do anything (default will load a page)
$(document).on 'drop', (e)->
  e.preventDefault && e.preventDefault()
  return

files_waiting_upload = []

$(document).on 'drop', '.upload_file', (e)->
  e.stopPropagation && e.stopPropagation()
  e.preventDefault && e.preventDefault()
  try
    file = event.dataTransfer.files
  catch
    alert("Browser supports drag and drop, but not in that way.")

  for indvfile in file
    files_waiting_upload.push(indvfile)
  start_upload(this)


$(document).on 'ajax:success', '.upload_file_delete', (data,status,xhr)->
  image_field = $(this).parents(".image_field")
  image_field.fadeOut ->
    image_field.remove()
  image_field.parent().find(".upload_file .upload_file_id").val(null)

show_image_field = (data,thethis)->
  newurl = data['public_url'].replace(".png",'_small.png')
  newurl = newurl.replace(".jpeg","_small.jpeg")
  newurl = newurl.replace(".jpg","_small.jpg")
  newurl = newurl.replace(".gif","_small.gif")
  console.log(newurl);
  $(thethis).before('<div class="image_field">
              <img src='+newurl+'>
              <a class="upload_file_delete btn btn-danger btn-xs" data-confirm="Are you sure?" data-method="delete" data-remote="true" href="/admin/public_files/'+data['id']+'" rel="nofollow">×</a>
            </div>')

start_upload = (thethis,data)=>
  action = $(thethis).data('upload-action')
  if files_waiting_upload.length != 0
    upload_file(files_waiting_upload.pop(),thethis)
  else if action == 'refresh'
    window.location.reload()
  else if action == 'showfield'
    show_image_field(data,thethis)
  else
    alert('unknown action')

upload_file = (file,thethis)=>
  formData = new FormData();
  formData.append($(thethis).data('upload-file-param'),file)
  percentage = 0
  upload_bar = $('<div class="progress"><div class="progress-bar progress-bar-striped active" style="width:0%"></div></div>')
  $.ajax
    url: $(thethis).data('upload-url')
    data: formData
    processData: false
    contentType: false
    type: 'POST'
    dataType: 'json'
    beforeSend: =>
      $(thethis).removeClass('draggable').removeClass('clickable')
      $(thethis).addClass('uploading').append(upload_bar)
    upload_progress: (e)->
      if e.lengthComputable
        percentage = (event.loaded / event.total * 100 | 0)
        upload_bar.find('.progress-bar').css("width","#{percentage}%")
    upload_complete: (e)->
      upload_bar.find('.progress-bar').css("width","#100%")
      upload_bar.find('.progress-bar').text("Complete; Please Wait.")
    complete: (e)->
      $(thethis).removeClass('uploading')
      upload_bar.remove()
    success: (data,textStatus,xhr)=>
      $(thethis).find(".upload_file_id").val(data['id'])
      start_upload(thethis,data)
    error: (xhr,textStatus,errorThrown)->
      console.log("Error")
      console.log(xhr)
      console.log(textStatus)
      console.log(errorThrown)
      if xhr.status == 422
        alert(xhr.responseText)
      else
        alert("ERROR: #{errorThrown}")  
      $(thethis).addClass('draggable').addClass('clickable')
      $(thethis).removeClass('uploading')
