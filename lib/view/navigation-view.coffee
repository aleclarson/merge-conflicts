{CompositeDisposable} = require 'atom'
{CoveringView} = require './covering-view'

class NavigationView extends CoveringView

  @content: ->
    @div class: 'controls navigation', =>
      @text ' '
      @span class: 'pull-right', =>
        @button class: 'btn btn-xs previous-unresolved', click: 'up', outlet: 'prevBtn', 'prev'
        @button class: 'btn btn-xs next-unresolved', click: 'down', outlet: 'nextBtn', 'next'

  initialize: (@conflict, editor) ->
    @subs = new CompositeDisposable

    super editor, 'navigation-overlay'

    @prependKeystroke 'merge-conflicts:previous-unresolved', @prevBtn
    @prependKeystroke 'merge-conflicts:next-unresolved', @nextBtn

    @subs.add @conflict.onDidResolveConflict =>
      @deleteMarker @cover()
      @remove()
      @cleanup()

  cleanup: ->
    super
    @subs.dispose()

  cover: -> @conflict.separatorMarker

  up: ->
    { prevConflict } = @conflict
    return if not prevConflict
    @scrollTo prevConflict.scrollTarget()

  down: ->
    { nextConflict } = @conflict
    return if not nextConflict
    @scrollTo nextConflict.scrollTarget()

  toString: -> "{NavView of: #{@conflict}}"

module.exports =
  NavigationView: NavigationView
