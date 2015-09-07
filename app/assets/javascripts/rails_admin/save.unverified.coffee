$(document).on "rails_admin.dom_ready", ->
  $('button[name="_save_unverified"]').on "click", ->
    $('input.skip_validation').val(true)