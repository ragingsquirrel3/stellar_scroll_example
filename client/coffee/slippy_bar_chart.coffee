define ['jquery', 'd3'], ($, d3) ->
  class SlippyBarChart
    CHART_PADDING = 50

    timeScale: null
    data: null
    xScale: null
    yScale: null

    constructor: (options={}) ->
      @timeScale = options.timeScale if options.timeScale
      @data = options.data if options.data
      windowHeight = options.windowHeight ? 400

      @yScale = d3.scale.linear()
        .domain([0, 25000])
        .range([windowHeight-CHART_PADDING, CHART_PADDING])

    render: (options={}) ->
      yearAtLeft = options.yearAtLeft ? @timeScale.domain()[0]
      xLeft = options.xLeft ? 0

      bars = d3.select('#bar-target').selectAll('.bar').data @data

      # enter
      bars.enter().append('div')
        .attr
          class: (d) -> "#{d.klass} bar"

      # update
      bars
        .style
          width: "#{CHART_PADDING}px"
          height: (d) => "#{@yScale d.price}px"
          bottom: "#{CHART_PADDING}px"
          left: (d, i) =>
            # original point along timeline
            xAtYear = @timeScale d.year
            # if scrolling position is less than timeline position, scroll with page
            if (xLeft + ((i + 1) * CHART_PADDING)) < xAtYear
              "#{xAtYear}px"
            # otherwise, final 'fixed' state
            else
              "#{(xLeft + ((i + 1) * CHART_PADDING))}px"

      # exit
      bars.exit().remove()
          

