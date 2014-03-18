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

requirejs ['jquery', 'd3', 'slippy_bar_chart', 'stellar'], ($, d3, SlippyBarChart) ->

  # make each scrolling zone's width equal to window width
  $('.scrolling-zone').width $(window).width()

  # TEMP
  # declare a scalle from year 500 BCE to 2050, with range corresponding to height
  timeScale = d3.scale.linear()
    .domain([-1500, 2050])
    .range([0, 8000])
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

  data = [
    {
      year: -500
      price: 10000
    },
    {
      year: -400
      price: 20000
    },
    {
      year: 1200
      price: 1000
    }
  ]

  chart = new SlippyBarChart
    timeScale: timeScale
    windowHeight: $(window).height()
    data: data
  chart.render()

  $(window).scroll (e) ->
    _yearAtLeft = timeScale.invert $(window).scrollLeft() + 50
    chart.render
      yearAtLeft: _yearAtLeft

  # activate stellar scroll parallax scroll effect
  $(window).stellar()
