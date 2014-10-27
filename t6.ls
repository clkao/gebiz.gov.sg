require! <[cheerio fs minimist csv]>
argv = minimist process.argv.slice 2

[t6, t15] = argv._

var info
suppliers = []
$ = cheerio.load fs.readFileSync t6, \utf-8
$ '#Table6 tr' .map ->
  [k, v] = $ @ .find 'td' .map ->
    $ @ .text! - /^\s+|\s+$/g
  if k is /^AWARDED SUPPLIER/
    suppliers.push info if info
    info := {}
  else
    info[k] = v

suppliers.push info
contract = {}
$ = cheerio.load fs.readFileSync t15, \utf-8
$ '#Table15 tr' .map ->
  [k, v, k2, v2] = $ @ .find 'td' .map ->
    $ @ .text! - /^\s+|\s+$/g - /:$/g

  contract[k] = v
  contract[k2] = v2 if k2

contract['Awarding Entity'] = delete contract['Name']

#console.log contract, suppliers

contract-fields = ["ITT No.", "ITQ No.", "Award Date", "Procurement Method", "Procurement Nature", "Awarding Entity", "Description", "Total Awarded Value"]
supplier-fields = ["Name of Supplier", "Address", "Awarded Value"]

stringify = require 'csv-stringify'
stringifier = stringify delimiter: ','
#stringifier.write contract-fields ++ supplier-fields

stringifier.pipe(process.stdout)

for c in suppliers
  stringifier.write [contract[k] for k in contract-fields] ++ [c[k] for k in supplier-fields]
stringifier.end()
