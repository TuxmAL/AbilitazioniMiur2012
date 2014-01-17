#!/bin/env ruby
# -*- coding: utf-8 -*-
# AbilitazioniMiur2012.
# Questo programma permette di scaricare in un unico file CSV tutti e soli gli 
# abilitati dei settori scientifico-disciplinari per il quale il MIUR ha creato
# le pagine di risultati. 
# Author::    TuxmAL (mailto:tuxmal@tiscali.it)
# Copyright:: Copyright (c) 2014 TuxmAL
# License::
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'

# Cerco i settori scientifico-disciplinari per cui esistono risultati.
doc = Nokogiri::HTML(open('http://abilitazione.miur.it/public/pubblicarisultati.php')) do |conf|
  conf.compact.noblanks.noent  
end
elenco_settori = doc.xpath("//select[@name='settore']/option[@value != '']")
puts "I settori attualmente presi in considerazione sono #{elenco_settori.length}."
settori = elenco_settori.map {|x| x['value']}
print 'I settori scaricato sono: '
print settori.join(', ')
puts '.'
#settori = %w( 01/A2 01/A3 01/A4 01/A5 01/A6 02/A2 02/B1 02/B2 02/B3 02/C1 03/A1 03/B1 03/C1 03/C2 04/A2 04/A3 05/B1 05/H2 06/A1 06/A2 06/A4 06/B1 06/C1 06/D1 06/D3 06/D4 06/E1 06/F4 06/H1 06/L1 07/B1 07/F1 07/F2 07/G1 07/H1 07/H2 07/H3 07/H5 08/A1 08/A2 08/A4 08/B2 08/B3 09/B1 09/E2 09/E4 09/F2 09/H1 10/D2 10/D3 10/D4 10/E1 10/G1 10/H1 10/M1 10/N3 11/A1 11/A2 11/A3 11/A4 11/A5 11/C1 11/C2 11/C4 11/D1 11/E3 12/A1 12/B1 12/C2 12/D1 12/D2 12/E2 12/E3 12/G2 12/H3 13/A2 13/A3 13/A4 13/A5 13/B1 13/B2 13/B5 14/A1 14/B1 14/C1 14/D1 )

CSV::open("sc_ab.csv", "wb:ISO8859-15", {:col_sep => ';'}) do |csv|
  csv << ['settore', 'fascia', '#', 'cognome', 'nome', 'pareri pro veritate', 'abilitato']
  settori.each do |settore| 
    sett = settore.split('/')
    # Get a Nokogiri::HTML::Document for the page were interested in...
    (1..2).each do |fascia|
      doc = Nokogiri::HTML(open("https://abilitazione.cineca.it/ministero.php/public/elencodomande/settore/#{sett.first}%252F#{sett.last}/fascia/#{fascia}"))  do |conf| 
        conf.compact.noblanks.noent
      end
      abilitati = doc.xpath("//table[@id='elencodomande']/tbody/tr/td[b='Si']")
      abilitati.each do |abile|
        celle_riga = abile.parent.xpath('(./th|td)[normalize-space()]')    
        csv << [settore, fascia] + celle_riga.map {|el| el.text.strip}
      end
    end
  end
#  puts "wget https://abilitazione.cineca.it/ministero.php/public/elencodomande/settore/#{p.first}%252F#{p.last}/fascia/1"
#  puts "wget https://abilitazione.cineca.it/ministero.php/public/elencodomande/settore/#{p.first}%252F#{p.last}/fascia/2"
end

# selettore da leggere 'elencodomande' per elemento <table>