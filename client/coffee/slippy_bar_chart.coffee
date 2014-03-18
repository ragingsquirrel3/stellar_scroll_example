define ['jquery', 'd3'], ($, d3) ->
  class SlippyBarChart
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
        .range([windowHeight-50, 50])

    render: (options={}) ->
      console.log 'data: ', @data

      bars = d3.select('#bar-target').selectAll('.bar').data @data

      # enter
      bars.enter().append('div')
        .attr
          class: 'bar'


      # update
      bars
        .style
          width: '50px'
          height: (d) => "#{@yScale d.price}px"
          left: (d, i) -> "#{i * 50 + 50}px"
          bottom: '50px'

            

      # exit
      bars.exit().remove()
          

