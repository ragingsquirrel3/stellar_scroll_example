define ['jquery', 'd3'], ($, d3) ->
  class SlippyBarChart
    CHART_PADDING = 30
    CHART_SPACING = 5
    LABEL_HEIGHT = 128

    barWidth: CHART_PADDING
    timeScale: null
    data: null
    xScale: null
    yScale: null

    constructor: (options={}) ->
      @timeScale = options.timeScale if options.timeScale
      @data = options.data if options.data
      windowWidth = options.windowWidth ? 400
      windowHeight = options.windowHeight ? 400

      # calc bar width based on window size and data points
      @barWidth = (windowWidth - (2 * CHART_PADDING)) / @data.length - CHART_SPACING

      @yScale = d3.scale.linear()
        .domain([0, 100000])
        .range([0, windowHeight- 2* CHART_PADDING])

    # from the d param, return a string of html content used build the labels
    _labelHtmlForData: (d) ->
      """
        <div class='#{d.klass} bar-label'>
          <h1 class='label-price'>$#{d.price}</h1>
          <p>#{d.label}</p>
        </div>
      """

    # helper function for 'fixed place'
    _fixedLeftFromData: (d, i, xLeft) ->
      (xLeft + (i * (@barWidth + CHART_SPACING)) + CHART_PADDING)

    render: (options={}) ->
      yearAtLeft = options.yearAtLeft ? @timeScale.domain()[0]
      xLeft = options.xLeft ? 0
      data = options.data
      yScale = @yScale

      # *** BARS ***
      bars = d3.select('#bar-target').selectAll('.bar').data data

      # enter
      bars.enter().append('div')
        .attr
          class: (d) -> "#{d.klass} bar"
        .style
          width: "#{@barWidth}px"
          height: '0px'
          bottom: "#{CHART_PADDING}px"
        .each (d) ->
          d3.select(@).transition().duration(1000)
            .style
              height: (d) => "#{Math.max(yScale(d.price), 1)}px"
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
