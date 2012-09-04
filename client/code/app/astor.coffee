AppRouter = Backbone.Router.extend({
 
  routes:{
    "live/:ids"    : "live",
    "archive/:ids" : "archive"
  },

  initialize: ->

    # Enable datepicker for the Archive
    $('#from').datepicker({format: 'dd-mm-yyyy'}).on('changeDate', (ev) ->
      window._from = ev.date
    )
    $('#to').datepicker({format: 'dd-mm-yyyy'}).on('changeDate', (ev) ->
      window._to = ev.date
    )

    # Archived Metrics list
    this.archivedMetrics     = new ArchivedMetricsCollection()
    this.archivedMetricsView = new ArchivedMetricsView({collection: this.archivedMetrics})
    this.archivedMetrics.fetch()
    $('#archive_metrics').html(this.archivedMetricsView.render().el)

    # Archived Metrics chart
    this.archivedChartCollection = new ArchivedMetricsCollection()
    this.archiveView = new ArchiveView({collection: this.archivedChartCollection})

    # Live Metrics list
    this.liveMetrics = new LiveMetricsCollection()
    this.liveMetricsView = new LiveMetricsView({collection: this.liveMetrics})
    $('#live_metrics').html(this.liveMetricsView.render().el)

    # Live Metrics chart
    this.liveChartCollection = new LiveChartCollection()
    this.liveChartView = new LiveChartView({collection: this.liveChartCollection})

    # Alerts
    this.alertsCollection = new AlertsCollection()
    this.alertsView = new AlertsView({collection: this.alertsCollection})
    $('#alerts_list').html(this.alertsView.render().el)

    #this.alertsBadgeView = new AlertsBadgeView({collection: this.alertsCollection})
    #$('#alerts_count').html(this.alertsBadgeView.render().el)


  live: (ids) ->
    selected_ids = ids.split('+')
    _.each selected_ids, (id) ->
      type = id.split('-')[0]
      name = id.split('-').slice(1).join('.')

      # Initialize the LiveMetric
      metric  = new LiveMetric(id, name)
      App.liveMetrics.add(metric)

      # Show them in the chart
      metric = App.liveMetrics.get(id)
      App.liveChartCollection.add(metric)

  archive: (ids) ->
    selected_ids = ids.split('+')
    _.each selected_ids, (id) ->
      metric = new Metric(id: id)
      App.archivedChartCollection.add(metric)

})

# Pre-load templates
window.templateLoader = {
    load: (views, callback) ->
      deferreds = []
      $.each(views, (index, view) ->
        if window[view] 
          deferreds.push($.get('templates/' + view + '.html', (data) ->
            window[view].prototype.template = _.template(data)
          , 'html'))
        else 
          alert(view + " not found")
      )
      $.when.apply(null, deferreds).done(callback)
}

# Pre-laod templates and start the app.
templateLoader.load(['ArchivedMetricItemView', 'LiveMetricItemView', 'AlertItemView', 'AlertsBadgeView'], ->
  window.App = new AppRouter()
  Backbone.history.start({pushState: false})
)
