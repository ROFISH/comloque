jQuery.timeago.settings.allowFuture = true;
jQuery.timeago.settings.strings =
  prefixAgo: null,
  prefixFromNow: null,
  suffixAgo: "ago",
  suffixFromNow: "from now",
  seconds: "less than a minute",
  minute: "about a minute",
  minutes: "about %d minutes",
  hour: "about an hour",
  hours: "about %d hours",
  day: "about a day",
  days: "%d days",
  month: "about a month",
  months: "%d months",
  year: "about a year",
  years: "%d years",
  numbers: [],
  monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
  preOrdinals: ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""],
  postOrdinals: ["","st","nd","rd","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th","st","nd","rd","th","th","th","th","th","th","th","st"],
  today: "Today, ",
  yesterday: "Yesterday, "
  todayDateFormat: ["today","hour",":","minute"],
  yesterdayDateFormat: ["yesterday","hour",":","minute"],
  longDateFormat: ["month"," ","day",", ","hour",":","minute"]
  

_fg = _fg || {}

jQuery ->
  changetime = (elem)->
    if elem.data("interval")
       clearInterval(elem.data("interval"))
       elem.data("interval",null)
    if _fg["showExact"]
      hidate = $.timeago.datetime(elem)
    
      nowdate = new Date()
      todaydate = new Date(nowdate-(nowdate.getSeconds()*1000)-(nowdate.getMinutes()*1000*60)-(nowdate.getHours()*1000*60*60))
      yesterdate = new Date(todaydate-86400000)
      tomorrdate = new Date(todaydate.valueOf()+86400000)
      if tomorrdate < hidate
        dateformat = "longDateFormat"
      else if todaydate < hidate
        dateformat = "todayDateFormat"
      else if yesterdate < hidate
        dateformat = "yesterdayDateFormat"
      else
        dateformat = "longDateFormat"
      
      out = ""
      for format in jQuery.timeago.settings.strings[dateformat]
        hourformat = if hidate.getHours() < 10
          "0#{hidate.getHours()}"
        else
          hidate.getHours()
        minuteformat = if hidate.getMinutes() < 10
          "0#{hidate.getMinutes()}"
        else
          hidate.getMinutes()
        out += switch (format)
          when "today" then jQuery.timeago.settings.strings["today"]
          when "yesterday" then jQuery.timeago.settings.strings["yesterday"]
          when "month" then jQuery.timeago.settings.strings["monthNames"][hidate.getMonth()]
          when "day" then jQuery.timeago.settings.strings["preOrdinals"][hidate.getDate()]+hidate.getDate()+jQuery.timeago.settings.strings["postOrdinals"][hidate.getDate()]
          when "hour" then hourformat
          when "minute" then minuteformat
          else format
        
      elem.html(out)
    else
      elem.timeago()
  jQuery.liveReady "time.changeabletime", ->
    this.unbind("click.changeabletime").bind "click.changeabletime", ->
      # $.ajax({
      #   "url":"/login/toggle_changeable_time",
      #   "type": "POST",
      #   "async": "true"
      # })
      if _fg["showExact"] == true
        _fg["showExact"] = false
      else
        _fg["showExact"] = true
      $("time.changeabletime").each ->
        changetime $(this)
    
    changetime this
