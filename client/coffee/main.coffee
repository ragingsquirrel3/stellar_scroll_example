VENDOR = "vendor"
requirejs.config
  paths:
    'jquery': "#{VENDOR}/jquery.min"
    'backbone': "#{VENDOR}/backbone.min"
    'underscore': "#{VENDOR}/underscore.min"
    'jade': "#{VENDOR}/jade.min"
    'stellar': "#{VENDOR}/stellar.min"
    'd3': "#{VENDOR}/d3.min"
  shim:
    'jquery': exports: '$'
    'stellar':
      deps: ['jquery']
      exports: 'stellar'
    'backbone':
      deps: ['underscore', 'jquery']
      exports: 'Backbone'
    'underscore': exports: '_'
    'jade': exports: 'jade'
    'd3': exports: 'd3'

requirejs ['jquery', 'd3', 'slippy_bar_chart', 'underscore', 'stellar'], ($, d3, SlippyBarChart, _) ->

  # make each scrolling zone's width equal to window width
  $('.scrolling-zone').width $(window).width()


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
      .domain([-2500, 3000])
      .range([0, 12000])
    axisFn = d3.svg.axis()
      .orient('top')
      .scale(timeScale)

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
      xLeft = $(window).scrollLeft()
      _yearAtLeft = timeScale.invert xLeft + 50
      chart.render
        yearAtLeft: _yearAtLeft
        xLeft: xLeft
        data: if _yearAtLeft < 2000 then preModernData else data


    # activate stellar scroll parallax scroll effect
    $(window).stellar verticalScrolling: false
