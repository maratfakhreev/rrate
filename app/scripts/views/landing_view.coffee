Timer = require('scripts/services/timer')

class LandingView extends Marionette.ItemView
  MAP_COUNTER_DURATION = 3000
  MOVING_DURATION = 800

  el: 'body'

  template: false

  ui:
    header: 'header'
    footer: 'footer'
    head: '.head'
    headPicture: '.head-picture'
    page: '.js-page'
    menuButton: 'nav li'
    mapSlider: '.map-slider-screen'
    mapButton: '.map-buttons li'
    plane: '.plane'
    layerOne: '.layer-one'
    layerTwo: '.layer-two'
    layerThree: '.layer-three'
    layerFour: '.layer-four'
    layerFive: '.layer-five'
    currentMapSlide: '.schemes > .active'
    marker: '.marker'

  events:
    'click @ui.menuButton': 'onMoveToScreen'
    'click @ui.mapButton': 'onClickMapButton'
    'mousemove': 'onMoveHeadBackground'

  initWindowEvents: ->
    @ui.wind.on 'scroll', @onScrollHeader
    @ui.wind.on 'scroll', @onScrollPages
    @ui.wind.on 'scroll', @onRefreshCounter
    @ui.wind.on 'resize', @onResize

  onRender: ->
    @ui.wind = $(window)
    setTimeout(=>
      @_pageDimensions()
    , 10)
    @offsetArray = @_calcOffsetArray()
    @initWindowEvents()

  onScrollHeader: =>
    if @ui.wind.scrollTop() < @windowHeight
      @ui.header.removeClass('displayed')
      @ui.footer.removeClass('displayed')
    else
      @ui.header.addClass('displayed')
      @ui.footer.addClass('displayed')

  onScrollPages: =>
    fromTop = @ui.wind.scrollTop()

    _.each @offsetArray, (value, key) =>
      if fromTop > value - 200 and fromTop < @offsetArray[key + 1]
        @ui.menuButton.removeClass('active').eq(key).addClass('active')

  onRefreshCounter: =>
    fromTop = @ui.wind.scrollTop()
    mapSliderTop = @ui.mapSlider.offset().top
    mapSliderBottom = mapSliderTop + @ui.mapSlider.height()

    if fromTop < mapSliderTop - @windowHeight or fromTop > mapSliderBottom
      @isActiveCounter = true
      @ui.marker.find('.counter-value').html('0')
    else if fromTop > mapSliderTop or fromTop < mapSliderBottom
      @setCounters(@isActiveCounter)
      @isActiveCounter = false

  onResize: =>
    @_pageDimensions()

  onMoveToScreen: (event) ->
    self = $(event.currentTarget)
    index = self.index()
    fromTop = @ui.page.eq(index).offset().top

    @$el.animate
      scrollTop: fromTop
      MOVING_DURATION
    , =>
      @ui.menuButton.removeClass('active')
      self.addClass('active')

  onClickMapButton: (event) ->
    self = $(event.currentTarget)
    index = self.index()
    $map = self.closest('.map')

    @ui.marker.find('.counter-value').html('0')
    @isActiveCounter = true
    @ui.mapButton.removeClass('active')
    self.addClass('active')
    $map.find('.schemes li').removeClass('active').eq(index).addClass('active')
    @setCounters(@isActiveCounter)

  onMoveHeadBackground: (event) ->
    @_setShift(event, @ui.layerTwo, 0.003, 0)
    @_setShift(event, @ui.layerThree, 0.01, 0)
    @_setShift(event, @ui.layerFour, -0.015, 0.015)
    @_setShift(event, @ui.layerFive, -0.015, -0.015)
    @_setLinearShift(event, @ui.plane, 0.1)

  setCounters: (isActive) ->
    if isActive
      $marker = @ui.currentMapSlide.find('.marker')

      _.each $marker, (value, key) =>
        $self = $(value)
        $selector = $self.find('.counter-value')
        maxCount = $self.data('value')
        @_counter(maxCount, $selector)

  _counter: (value, $selector) ->
    counter = 0
    counterFunction = setInterval(->
      $selector.html(counter++)
      clearInterval(counterFunction) if counter is value
    , MAP_COUNTER_DURATION / value)

  _setShift: (event, $selector, xCoef, yCoef) ->
    $selector.css('background-position', "#{xCoef * event.pageX}px #{yCoef * event.pageY}px")

  _setLinearShift: (event, $selector, xCoef) ->
    $selector.css({
      bottom: "#{500 + xCoef / 5 * event.pageX}px",
      left: "#{200 + xCoef * event.pageX}px"
    })

  _windowHeight: ->
    @ui.wind.height()

  _calcOffsetArray: ->
    array = []

    _.each @ui.page, (value, key) ->
      array.push($(value).offset().top)

    array.push(Number.MAX_SAFE_INTEGER)
    array

  _pageDimensions: ->
    @windowHeight = @_windowHeight()
    @ui.head.css('height': @windowHeight)
    @ui.headPicture.css('height': @windowHeight - 90)

module.exports = LandingView
