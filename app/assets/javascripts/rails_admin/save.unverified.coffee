bindSaveUnverified = ->
  button = $('button[name="_save_unverified"]')
  button.toggle !!$('.has-error').length
  button.on "click", ->
    $('input.skip_validation').val(true)
$(document).on "rails_admin.dom_ready", ->
  bindSaveUnverified()

