{CompositeDisposable} = require 'atom'
{View, $} = require 'space-pen'
_ = require 'underscore-plus'


class CoveringView extends View

  initialize: (@editor, overlayClass) ->
    @coverSubs = new CompositeDisposable
    @overlay = @editor.decorateMarker @cover(),
      type: 'overlay',
      class: overlayClass,
      item: this,
      position: 'tail'

    @coverSubs.add @editor.onDidDestroy => @cleanup()

  attached: ->
    view = atom.views.getView(@editor)
    @parent().css right: view.getVerticalScrollbarWidth()

    @css 'margin-top': -@editor.getLineHeightInPixels()
    @height @editor.getLineHeightInPixels()

  cleanup: ->
    @coverSubs.dispose()

    @overlay?.destroy()
    @overlay = null

  # Override to specify the marker of the first line that should be covered.
  cover: -> null

  # Override to return the Conflict that this view is responsible for.
  conflict: -> null

  isDirty: -> false

  # Override to determine if the content of this Side has been modified.
  detectDirty: -> null

  # Override to apply a decoration to a marker as appropriate.
  decorate: -> null

  getModel: -> null

  buffer: -> @editor.getBuffer()

  includesCursor: (cursor) -> false

  deleteMarker: (marker) ->
    @buffer().delete marker.getBufferRange()
    marker.destroy()

  scrollTo: (position) ->
    return if position is undefined
    cursor = @editor.cursors[0].marker
    prevPos = cursor.getStartScreenPosition()
    @editor.setCursorBufferPosition position
    return if position is null
    nextPos = cursor.getStartScreenPosition()
    if prevPos.row < nextPos.row
      @editor.scrollToScreenPosition [ nextPos.row + 10, 0 ]
    else
      @editor.scrollToScreenPosition [ nextPos.row - 7, 0 ]

  prependKeystroke: (eventName, element) ->
    bindings = atom.keymaps.findKeyBindings command: eventName

    for e in bindings
      original = element.text()
      element.text(_.humanizeKeystroke(e.keystrokes) + " #{original}")

module.exports =
  CoveringView: CoveringView
