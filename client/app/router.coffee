app = require 'application'
ListView = require 'views/list_view'
CalendarView = require 'views/calendar_view'
EventModal = require 'views/event_modal'
ImportView = require 'views/import_view'
AlarmCollection = require 'collections/alarms'

module.exports = class Router extends Backbone.Router

    routes:
        ''                     : -> @navigate 'calendar', true
        'calendar'             : 'calendar'
        'calendarweek'         : 'calendarweek'
        'calendar/:eventid'    : 'calendar_event'
        'calendarweek/:eventid': 'calendarweek_event'
        'alarms'               : 'alarmsList'
        'import'               : 'import'

    calendar: (fcView = 'month') ->
        @displayView new CalendarView
            view: fcView
            model: {alarms:app.alarms, events:app.events}
        app.menu.activate 'calendar'
        @handleFetch app.alarms, "alarms"
        @handleFetch app.events, "events"

    calendarweek: ->
        @calendar 'agendaWeek'

    alarmsList: ->
        @displayView new ListView
            collection: app.alarms
        app.menu.activate 'alarms'
        @handleFetch @mainView.collection, "alarms"

    calendar_event: (id) ->
        @calendar() unless @mainView instanceof CalendarView
        @event id

    calendarweek_event: (id) ->
        @calendarweek() unless @mainView instanceof CalendarView
        @event id

    event: (id) ->
        model = app.events.get(id) or new Event(id: id).fetch()
        view = new EventModal(model: model)
        $('body').append view.$el
        view.render()

    import: ->
        @displayView new ImportView()
        app.menu.activate 'import'

    handleFetch: (collection, name) ->
        unless app[name].length > 0
            collection.fetch
                success: (collection, response, options) ->
                    console.log collection
                    console.log "Fetch: success"
                error: ->
                    console.log "Fetch: error"
        else
            collection.reset app[name].toJSON()

    # display a page properly (remove previous page)
    displayView: (view) =>
        @mainView.remove() if @mainView
        @mainView = view
        $('body').append @mainView.$el
        @mainView.render()
