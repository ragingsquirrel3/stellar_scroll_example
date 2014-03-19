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
        <h1>#{d.label}<h1>
        <h1 class='label-price'>$#{d.price}</h1>
      """

    render: (options={}) ->
      yearAtLeft = options.yearAtLeft ? @timeScale.domain()[0]
      xLeft = options.xLeft ? 0

      # *** BARS ***
      bars = d3.select('#bar-target').selectAll('.bar').data @data

      # enter
      bars.enter().append('div')
        .attr
          class: (d) -> "#{d.klass} bar"

      # update
      bars
        .style
          width: "#{@barWidth}px"
          height: (d) => "#{@yScale d.price}px"
          bottom: "#{CHART_PADDING}px"
          left: (d, i) =>
            # original point along timeline
            xAtYear = @timeScale d.year
            # if scrolling position is less than timeline position, scroll with page
            if (xLeft + (i * (@barWidth + CHART_SPACING)) + CHART_PADDING) < xAtYear
              "#{xAtYear}px"
            # otherwise, final 'fixed' state
            else
              "#{(xLeft + (i * (@barWidth + CHART_SPACING)) + CHART_PADDING)}px"

            # te,p
            # "#{xAtYear}px"

      # exit
      bars.exit().remove()

      # *** LABELS ***
      labels = d3.select('#bar-target').selectAll('.bar-label').data @data

      labels.enter().append('div')
        .attr
          class: (d) -> "#{d.klass} bar-label"
        .style
          top: (d) => "#{Math.max(Math.abs(@yScale.range()[1] - @yScale(d.price)) - LABEL_HEIGHT, @yScale.range()[0])}px"
        .html (d) =>
          @_labelHtmlForData d

      labels
        .style
          left: (d) => "#{@timeScale d.year}px"
          # top: '200px'

      labels.exit().remove()
