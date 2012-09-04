# This function is called from the template
exports.toggle = (id) ->
  metric = App.liveChartCollection.get(id)
  if metric
    App.liveChartCollection.remove(metric)
  else
    metric = App.liveMetrics.get(id)
    App.liveChartCollection.add(metric)


# WebSocket event handler for 'metric'
ss.event.on 'metric', (json) ->
  datapoint = new Datapoint(json)
  metric = App.liveMetrics.get(datapoint.id)
  if metric
    metric.update(datapoint)
  else
    metric = new LiveMetric(datapoint.id, datapoint.get('name'))
    metric.update(datapoint)
    App.liveMetrics.add(metric)
  

window.Datapoint = Backbone.Model.extend({
  initialize: (datapoint) ->
    this.set 'id', "#{datapoint.type}-#{datapoint.key.split('.').join('-')}"
    this.set 'type', datapoint.type
    this.set 'name', datapoint.key
    this.set 'timestamp', datapoint.timestamp
    this.set 'value', datapoint.value
})

window.LiveMetric = Backbone.Model.extend({
  # fuck this man, datapoints array was being cached 
  # and shared by multiple instances? wtf
  #defaults: {
  #  datapoints: [],
  #  count: 0
  #},

  initialize: (id, name) ->
    this.set 'id', id
    this.set 'name', name
    this.set 'datapoints', []
    this.set 'count', 0

  update: (point) ->
    this.trigger('add_point', point)
    #this.add_point(point)
    this.increment_counter()

  add_point: (point) ->
    #timestamp = point.get('timestamp')
    timestamp = moment(point.get('timestamp')).unix()
    value     = point.get('value')

    datapoints = this.get('datapoints')
    datapoints.push([timestamp, value])
    this.set({datapoints: datapoints})

  increment_counter: ->
    count = this.get('count')
    this.set('count', count + 1)


})

# Collection of the metrics shown in the LiveList
window.LiveMetricsCollection = Backbone.Collection.extend({
  model: LiveMetric,
})

# Collection of the metrics shown in the LiveChart
window.LiveChartCollection = Backbone.Collection.extend({
  model: LiveMetric,
})


# List of all the LIVE metrics streamed over WS
window.LiveMetricsView = Backbone.View.extend({
 
  tagName: 'ul'
  className:'nav nav-list'

  initialize: ->
    self = this
    this.collection.bind("reset", this.render, this)
    this.collection.bind("add", (metric) ->
      $(self.el).append(new LiveMetricItemView({model: metric}).render().el)
    )

  render: (eventName) ->
    _.each(this.collection.models, (metric) ->
      $(this.el).append(new LiveMetricItemView({model: metric}).render().el)
    , this)
    return this
 
})

# Chart of the LIVE metrics selected from the LiveList
window.LiveChartView = Backbone.View.extend({
  initialize: ->
    this.collection.bind("add", this.add_series, this)
    this.collection.bind("add", this.update_url, this)

    this.collection.bind("remove", this.remove_series, this)
    this.collection.bind("remove", this.update_url, this)

    this.collection.bind('add_point', this.add_point, this)
    this.chart = new Highcharts.Chart({
      chart: {
       renderTo: 'chart',
       type: 'spline',
       zoomType: 'x'
      },
      title: {
        text: ""
      },
      xAxis: {
       type: 'datetime'
      },
      yAxis: {
        title: {
          text: ''
        }
      },
      series: [],
      credits: {
        enabled: false
      }
    })

  add_series: (point) ->
    id    = point.id
    name  = point.get('name')
    data  = point.get('datapoints')
    this.chart.addSeries({id: id, name: name, data: data})

  remove_series: (point) ->
    this.chart.get(point.id).remove()

  update_url: ->
    ids = this.collection.models.map (m) ->
      m.id
    App.navigate("live/#{ids.join('+')}", {trigger: false})

  # TODO Refresh the chart periodically, not on every point added 
  add_point: (point) ->
    timestamp = moment(point.get('timestamp')).unix()
    value     = point.get('value')
    serie     = this.chart.get(point.id)
    if serie
      shift = serie.data.length > 60
      serie.addPoint([Date.now(), value], true, shift)

})

window.LiveMetricItemView = Backbone.View.extend({

  tagName:"li",

  initialize: ->
    this.model.bind("change", this.render, this)
    this.model.bind("destroy", this.close, this)
  ,

  render: ->
    $(this.el).html(this.template(this.model.toJSON()))
    return this
  ,

  events: {
    "click": "click_ev"
  }

  click_ev: ->
    #console.log this.model.attributes.metric

})

