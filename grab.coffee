casper = require('casper').create { clientScripts: ["bower_components/jquery/dist/jquery.min.js"] }
fs = require('fs')

{session, extra, supplyHead, output} = casper.cli.raw.options

# EPU/FBV/10

base = 'https://www.gebiz.gov.sg'

url = 'https://www.gebiz.gov.sg/scripts/openAreaForward.jsp?select=pasttenderId'

casper.start url, ->
  @page.onConsoleMessage = (msg) ->
    console.log('message: ' + msg)
  @echo @getTitle()

allLinks = []

allLinks.push '/scripts/main.do?doctype=TQ&doc=IDA000ETQ14000172&extSystemCode=E'

populate = ->
  extract = (cb) -> ->
    console.log "evaluating"
    [hrefs] = casper.evaluate =>
      console.log "evaluating"
      matched = $(document).text().match(/There are (\d+) records in total./)
      entries = matched[1]
      console.log 'total entries', entries
      console.log 'meh'
      hrefs = [node.getAttribute('href') for node in $('.link_underline')]
      console.log 'meh'
      hrefs
    last = casper.evaluate =>
      console.log "evaluating"
      last = $('input[name="strBtnNext"]').attr('disabled')
      last
    allLinks = allLinks.concat hrefs

    console.log "allright?", last
    cb hrefs, last
# PR: 'EPU/SER/32'
  casper.then -> @evaluate ->
    $('select[name="supplyHead"]').val 'EPU/FBV/10'
    $('select[name="awardStatus"]').val 'Awarded'

  doit = (btn) =>
    casper.thenClick btn, extract (hrefs, last) ->
      console.log "=====", hrefs, last
      allLinks = allLinks.concat hrefs
      unless last
        doit 'input[name="strBtnNext"]'
  doit 'input[name="submitAction"]'

populate()

casper.then ->
  allLinks.forEach (link) ->
    console.log "===+", link
    [_, itt] = link.match /doc=(.*?)&/
    console.log "itt", itt

    casper.thenOpen base + link, ->
      console.log("opening", link)
      @echo @getTitle()

    casper.thenClick 'a[href="/scripts/main.do?tab=award"]', ->
      fs.write "#{itt}-15", @getPageContent(), 'w'
      console.log "clicking award"
    casper.thenClick 'a[href="/scripts/main.do?section=details"]', ->
      fs.write "#{itt}-6", @getPageContent(), 'w'
      console.log "clicking details"

casper.run ->
    # display results
#    fs.write output, @getPageContent(), 'w'
    @exit()
