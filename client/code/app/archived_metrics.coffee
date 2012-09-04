exports.toggle = (id) ->
  metric = App.archivedChartCollection.get(id)
  if metric
    App.archivedChartCollection.remove(metric)
  else
    metric = new Metric(id: id)
    App.archivedChartCollection.add(metric)


window.Metric = Backbone.Model.extend({
  urlRoot: "http://#{ss.astor_api.host}:#{ss.astor_api.port}/v1/metrics",
  formated_data: ->
    _.map(this.attributes.data, (a) ->
      [Date.parse(a[0]), parseFloat(a[1])]
    )
})

window.ArchivedMetricsCollection = Backbone.Collection.extend({
  url: "http://#{ss.astor_api.host}:#{ss.astor_api.port}/v1/metrics",
  model: Metric,
})

window.ArchivedMetricsView = Backbone.View.extend({
 
  tagName: 'ul',
  className:'nav nav-list',

  initialize: ->
    self = this
    this.collection.bind("reset", this.render, this)
    this.collection.bind("add", (metric) ->
      $(self.el).append(new ArchivedMetricItemView({model:metric}).render().el)
    )
  ,

  render: (eventName) ->
    _.each(this.collection.models, (metric) ->
      $(this.el).append(new ArchivedMetricItemView({model: metric}).render().el)
    , this)
    return this
 
})

window.ArchivedMetricItemView = Backbone.View.extend({

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

window.ArchiveView = Backbone.View.extend({
  initialize: ->
    this.offset = '1days'

    this.collection.bind("add", this.fetch_datapoints, this)
    this.collection.bind("add", this.update_url, this)

    this.collection.bind("remove", this.remove, this)
    this.collection.bind("remove", this.update_url, this)

    this.collection.bind("change", this.add_series, this)

    this.chart = new Highcharts.Chart({
      chart: {
       renderTo: 'archive_chart',
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

  setOffset: (offset) ->
    this.offset = offset

  remove: (metric) ->
    this.chart.get(metric.id).remove()

  fetch_datapoints: (metric) ->
    metric.fetch({data: {offset: this.offset}})

  add_series: (metric) ->
    this.chart.addSeries({
      id:   metric.id,
      name: metric.get('key'),
      data: metric.formated_data()
    })

  update_url: ->
    ids = this.collection.models.map (m) ->
      m.id
    App.navigate("archive/#{ids.join('+')}", {trigger: false})

})
