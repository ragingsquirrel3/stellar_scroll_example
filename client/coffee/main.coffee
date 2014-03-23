VENDOR = "vendor"
requirejs.config
  paths:
    'jquery': "#{VENDOR}/jquery.min"
    'underscore': "#{VENDOR}/underscore.min"
    'jade': "#{VENDOR}/jade.min"
    'stellar': "#{VENDOR}/stellar.min"
    'd3': "#{VENDOR}/d3.min"
  shim:
    'jquery': exports: '$'
    'stellar':
      deps: ['jquery']
      exports: 'stellar'
    'underscore': exports: '_'
    'jade': exports: 'jade'
    'd3': exports: 'd3'

requirejs ['jquery', 'd3', 'slippy_bar_chart', 'underscore', 'stellar'], ($, d3, SlippyBarChart, _) ->
  NUM_SCROLLERS = 7
  SCROLLER_SIZE_FACTOR = 1.25
  promptIsVisible = true

  windowWidth = $(window).width()

  # make each scrolling zone's width equal to window width
  $('.scrolling-zone').width windowWidth * SCROLLER_SIZE_FACTOR
  $('#scroll-container').width windowWidth * NUM_SCROLLERS * SCROLLER_SIZE_FACTOR
  
  # on clicking the prompt, scroll a little to the right and hide the prompt
  $('#scroll-prompt').click (e) ->
    # TODO, scroll to the right
    console.log 'scroll me gently'
    promptIsVisible = false
    $(e.currentTarget).fadeOut()


  # open and parse the data csv, render when data is ready
  parseFn = (d) ->
    _year = if d.year.match('-')
      Number d.year.substring(0, 4)
    else if isNaN Number d.year
      2014
    else
      Number d.year
    price: Number(d.inflationAdjusted.split(',').join(''))
    year: _year
    label: "#{d.context} #{d.detail}"
    klass: d.klass ? ''

  # load the data and render
  d3.csv 'data2.csv', parseFn, (err, data) ->

    data = _.sortBy data, (d) -> d.year
    preModernData = _.filter data, (d) -> d.year < 2000

    # TEMP
    # declare a scalle from year 500 BCE to 2050, with range corresponding to height
    timeScale = d3.scale.linear()
      .domain([-2500, 4000])
      .range([0, windowWidth * NUM_SCROLLERS * SCROLLER_SIZE_FACTOR])
    axisFn = d3.svg.axis()
      .orient('top')
      .scale(timeScale)
      .tickFormat(d3.format())

    svg = d3.select('#viz').selectAll('svg').data([null])
    svg.enter().append('svg')

    axis = svg.selectAll('#time-scale').data([null])
    axis.enter().append('g')
      .attr
        id: 'time-scale'
        transform: "translate(0, 20)"
      .call axisFn

    # data = [
    #   {
    #     year: -500
    #     price: 10000
    #     klass: 'antiquity'
    #     label: 'Lorem Ipsy'
    #   },
    #   {
    #     year: -400
    #     price: 20000
    #     klass: 'antiquity'
    #     label: 'Zoo Fixx'
    #   },
    #   {
    #     year: 1200
    #     price: 1000
    #     klass: 'antiquity'
    #     label: 'Foo that Bar'
    #   }
    # ]

    chart = new SlippyBarChart
      timeScale: timeScale
      windowWidth: $(window).width()
      windowHeight: $(window).height()
      data: data
    chart.render
      data: preModernData

    $(window).scroll (e) ->
      if promptIsVisible then $('#scroll-prompt').fadeOut()
      xLeft = $(window).scrollLeft()
      _yearAtLeft = timeScale.invert xLeft + 50
      chart.render
        yearAtLeft: _yearAtLeft
        xLeft: xLeft
        data: if _yearAtLeft < 3000 then preModernData else data


    # activate stellar scroll parallax scroll effect
    $(window).stellar verticalScrolling: false
