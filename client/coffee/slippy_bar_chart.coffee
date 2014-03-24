define ['jquery', 'd3'], ($, d3) ->
  class SlippyBarChart
    CHART_PADDING = 30
    Y_PADDING = 55
    X_PADDING = 70
    CHART_SPACING = 5
    LABEL_HEIGHT = 128
    # data for time period labels
    ERA_LABELS_DATA = [
      {
        label: 'Slavery in Antiquity'
        year: -600
        klass: 'antiquity'
      },
      {
        label: 'Atlantic Slave Trade'
        year: 1250
        klass: 'colonial'
      },
      {
        label: 'Modern Human Trafficking'
        year: 3000
        klass: 'modern'
      }
    ]

    currentEra: 'antiquity' # antiquity, colonial, modern
    barWidth: CHART_PADDING
    windowHeight: null
    timeScale: null
    data: null
    xScale: null
    yScale: null

    constructor: (options={}) ->


      @timeScale = options.timeScale if options.timeScale
      @data = options.data if options.data
      windowWidth = options.windowWidth ? 400
      @windowHeight = options.windowHeight ? 400

      # calc bar width based on window size and data points
      @barWidth = (windowWidth - (2 * X_PADDING)) / @data.length - CHART_SPACING

      @yScale = d3.scale.linear()
        .domain([0, 100000])
        .range([@windowHeight - 2* Y_PADDING , Y_PADDING])

      @_renderyScale(windowWidth)

    _renderyScale: (width) ->
      yLinesfn = d3.svg.axis()
        .orient("right")
        .scale(@yScale)
        .tickSize(width-2*X_PADDING)

      commaformat = d3.format(",.0f")
      yAxisfn = d3.svg.axis()
        .orient("left")
        .scale(@yScale)
        .tickSize(-10, 3, 3)
        .tickFormat (d) ->
          "$" + commaformat(d)

      svg = d3.select('#y-axis').selectAll('svg').data([null])
      svg.enter().append('svg')

      yAxis = svg.selectAll('#price-scale').data([null])
      yAxis.enter().append('g')
        .attr
          id: "price-scale"
          transform: "translate(#{X_PADDING}, #{CHART_PADDING})"
        .call yAxisfn
      yAxisLines = svg.selectAll('#price-scale-lines').data([null])
      yAxisLines.enter().append('g')
        .attr
          id: 'price-scale-lines'
          transform: "translate(#{X_PADDING},#{CHART_PADDING})"
        .call yLinesfn

    # from the d param, return a string of html content used build the labels
    _labelHtmlForData: (d) ->
      priceAsString = "$#{d3.format(",.0f")(d.price)}"
      """
        <div class='#{d.klass} bar-label'>
          <h1 class='label-price'>#{priceAsString}</h1>
          <p>#{d.label}</p>
        </div>
      """

    # helper function for 'fixed place'
    _fixedLeftFromData: (d, i, xLeft) ->
      (xLeft + (i * (@barWidth + CHART_SPACING)) + X_PADDING)

    # based on year, selects which background should be active
    _changeBackgroundImage: (year) ->
      newEra = if year < -500
        'antiquity'
      else if year < 1400
        'colonial'
      else
        'modern'

      if newEra != @currentEra
        @currentEra = newEra
        $('.bg-zone').removeClass 'active'
        $(".bg-zone.#{@currentEra}").addClass 'active'

    render: (options={}) ->
      yearAtLeft = options.yearAtLeft ? @timeScale.domain()[0]
      xLeft = options.xLeft ? 0
      data = options.data
      yScale = @yScale
      windowHeight = @windowHeight

      # maybe change background
      @_changeBackgroundImage yearAtLeft

      # *** BARS ***
      bars = d3.select('#bar-target').selectAll('.bar').data data

      # enter
      bars.enter().append('div')
        .attr
          class: (d) -> "#{d.klass} bar"
        .style
          width: "#{@barWidth}px"
          height: '0px'
          bottom: "#{Y_PADDING+CHART_PADDING-CHART_SPACING}px"
        .each (d) ->
          d3.select(@).transition().duration(1000)
            .style
              height: (d) => "#{Math.max(windowHeight - 2 * Y_PADDING - yScale(d.price), 1)}px"
        .html (d) => @_labelHtmlForData d


      # update
      bars
        .style
          left: (d, i) =>
            # original point along timeline
            xAtYear = @timeScale d.year
            # if scrolling position is less than timeline position, scroll with page
            if @_fixedLeftFromData(d, i, xLeft) < xAtYear
              "#{xAtYear}px"
            # otherwise, final 'fixed' state
            else
              "#{@_fixedLeftFromData(d, i, xLeft)}px"
        .classed 'inactive', (d, i) =>
          xAtYear = @timeScale d.year
          !(@_fixedLeftFromData(d, i, xLeft) < xAtYear)
          
      # time period labels
      labels = d3.select('#bar-target').selectAll('.era-label').data ERA_LABELS_DATA
      
      # enter
      labels.enter().append('h1')
        .attr
          class: (d) -> "#{d.klass} era-label"
        .style
          top: (d, i) -> "#{(i + 1) * 1.25}em"
          left: (d) => "#{@timeScale(d.year)}px"
        .text (d) -> d.label
          
      #update
      labels
        .style
          left: (d, i) =>
            # original point along timeline
            xAtYear = @timeScale d.year
            # if scrolling position is less than timeline position, scroll with page
            if @_fixedLeftFromData(d, i, xLeft) < xAtYear
              "#{xAtYear}px"
            # otherwise, final 'fixed' state
            else
              "#{@_fixedLeftFromData(d, 0, xLeft)}px"
