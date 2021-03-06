# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  $('.icon').click ->
    $('.icon').removeClass('active')
    $(this).addClass('active')
    console.log($(this))
    iconName = $(this).data('icon')
    $('#time_type_icon').val(iconName)

  $('.clear-icon').click ->
    $('.icon').removeClass('active')
    $('#time_type_icon').val('')

  $('.color').click ->
    $('.color').removeClass('active')
    $(this).addClass('active')
    console.log($(this))
    colorIndex = $(this).data('color-index')
    $('#time_type_color_index').val(colorIndex)
