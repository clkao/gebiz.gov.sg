# Scraper for gebiz.gov.sg

## Usage

    % npm i -g phantomjs casperjs LiveScript

    % npm i cheerio csv-stringify minimist
    % casperjs grab.coffee
    % ls *-6|cut -f1 -d - | xargs -I % -n 1 lsc t6.ls %-6 %-15 >> /tmp/file.csv

## License: MIT

http://clkao.mit-license.org/
