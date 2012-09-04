# WebSocket event handler for 'alert'
ss.event.on 'alert', (json) ->
  alert = new Alert(json)
  App.alertsCollection.add(alert)

window.Alert = Backbone.Model.extend({
  initialize: (alert) ->
    this.set 'id', alert.timestamp
    this.set 'type', alert.type
    this.set 'name', alert.key
    this.set 'timestamp', alert.timestamp
    this.set 'reason', alert.reason
    this.set 'severity', alert.severity
})

window.AlertsCollection = Backbone.Collection.extend({
  model: Alert
})

window.AlertsView = Backbone.View.extend({
 
  tagName: 'ul'
  className: 'alerts_list'

  initialize: ->
    self = this
    this.collection.bind("reset", this.render, this)
    this.collection.bind("add", (alert) ->
      $(self.el).prepend(new AlertItemView({model: alert}).render().el)
    )

  render: (eventName) ->
    _.each(this.collection.models, (Alert) ->
      $(this.el).prepend(new AlertItemView({model: alert}).render().el)
    , this)
    return this
 
})

window.AlertItemView = Backbone.View.extend({

  tagName:"li"

  initialize: ->
    this.model.bind("change", this.render, this)
    this.model.bind("destroy", this.close, this)

  render: ->
    console.log this.model.toJSON()
    $(this.el).html(this.template(this.model.toJSON()))
    return this

})

window.AlertsBadgeView = Backbone.View.extend({

  tagName: 'span'
  className: 'badge badge-important'

  initialize: ->
    this.collection.bind("add", this.render, this)

  render: ->
    #console.log JSON.stringify({count: this.collection.size})
    #$(this.el).html(this.template(json))
    return this

})

