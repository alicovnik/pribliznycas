addEvent = (name, cb) ->
  if document.addEventListener
    document.addEventListener name, cb, false
    true
  else if document.attachEvent
    document.attachEvent 'on' + name, cb
    true
  else
    false

DEFAULT_TIER = 4

pref =
  validate: (tier) ->
    Math.min(Math.max(tier, 0), tiers.length - 1)
  get: ->
    @validate localStorage?.getItem?('tier') or DEFAULT_TIER
  set: (tier) ->
    tier = @validate tier
    localStorage?.setItem 'tier', tier
    tier
  minus: ->
    @set @get() - 1
  plus: ->
    @set @get() + 1

tiers = [
  # nekdy
  (ts) -> 'někdy'
  # 2014
  (ts) -> moment().format('YYYY')
  # duben
  (ts) -> moment().format('MMMM')
  # pondeli
  (ts) -> moment().format('dddd')
  # dopoledne
  (ts) ->
    hours = moment().hours()
    switch
      when 6 <= hours < 9
        'ráno'
      when 9 <= hours < 11
        'dopoledne'
      when 11 <= hours < 13
        'kolem oběda'
      when 13 <= hours < 18
        'odpoledne'
      when 18 <= hours < 22
        'večer'
      else
        'noc'
  # pet
  (ts) ->
    hour = moment().hours()
    minutes = moment().minutes()
    if minutes > 45
      hour = (hour + 1)
    [
      'půlnoc'
      'jedna'
      'dvě'
      'tři'
      'čtyři'
      'pět'
      'šest'
      'sedm'
      'osm'
      'devět'
      'deset'
      'jedenáct'
      'poledne'
      'jedna'
      'dvě'
      'tři'
      'čtyři'
      'pět'
      'šest'
      'sedm'
      'osm'
      'devět'
      'deset'
      'jedenáct'
    ][hour]
  # ctvrt
  (ts) ->
    strings = [
      'celá a něco'
      'za chvíli čtvrt'
      'čtvrt'
      'po čtvrt'
      'bude půl'
      'půl'
      'po&nbsp;půl'
      'hnedle tři&nbsp;čtvrtě'
      'tři čtvrtě'
      'po tři čtvrtě'
      'bude celá'
      'celá'
    ]
    size = strings.length
    index = ((moment().minutes() / 60) * size) - 0.5
    index = if index<0 then (index+size) else index
    strings[parseInt(index)]
]

getTime = (tier) ->
  tiers[tier]()

# inspired by https://github.com/adactio/FitText.js
fitText = ->
  container = document.getElementById('timeContainer')
  text = document.getElementById('time')?.innerHTML
  if !text or !container
    return
  longestWord = text.split(' ').sort((a, b) -> b.length - a.length)[0].length
  MAX_FONT_SIZE = 200
  MIN_FONT_SIZE = 30
  container?.style.fontSize = Math.max(Math.min(
    container.clientWidth / (Math.log(longestWord) * 2.5), MAX_FONT_SIZE
    ), MIN_FONT_SIZE) + 'px'

addEvent 'resize', fitText

render = ->
  tier = pref.get()
  document.getElementById('controls').className = 'tier' + tier
  document.getElementById('time').innerHTML = getTime tier
  fitText()

render()
setInterval render, 1000 # once per second is more than enough

onclick = (e) ->
  e.preventDefault()
  if /less/.exec e.target.className
    pref.minus()
    render()
  else if /more/.exec e.target.className
    pref.plus()
    render()

if !addEvent 'click', onclick
  # if adding event fails, hide controls
  document.getElementById('controls').style.display = 'none'
