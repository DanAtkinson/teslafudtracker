require 'news-api'
require 'date'
require 'erb'
require 'colorize'

@articles = Array.new
wordCount = Hash.new
fudAuthorCount = Hash.new
fudSourceCount = Hash.new
authorCount = Hash.new
sourceCount = Hash.new
@fudDates = Hash.new

def chalkUp(hash,word)
  if hash.has_key?(word)
    hash[word] = hash[word] + 1
  else
    hash[word] = 1
  end
  hash
end

fileData = IO.read("data.json")
jsonData = JSON.parse(fileData)

definitelyTesla = /[Tt]esla|[Mm]usk|[Ee]lon/
fudwords = / desperate | rattle| worried |in trouble| fear| drugs | scare |poorly built|[Ss]uppliers.*[Rr]isk|[Dd]elivered with [Ff]laws|total fraud|grueling|([Ff]ormer|[Ee]x[- ])[Tt]esla| (doom|doomed) |bankrupt|cash (problem|crunch)|Tesla insider|lose money|losing (faith|confidence)|(growing|raising|raised) concerns|xperts doubt|nalysts warn|scrambling/
negate = /([Hh]ire|[Hh]iring)|brings on|little to fear|memes/

scanDate = DateTime.now.to_date.to_s

jsonData.each do |entry|
  if (entry["description"]  =~ fudwords || entry["title"]  =~ fudwords) && (entry["description"]  =~ definitelyTesla || entry["title"] =~ definitelyTesla)

    #Negate
    if (entry["description"]  =~ negate || entry["title"]  =~ negate)
      next
    end

    puts "FUD from #{entry["source"]} - #{entry["author"]} - #{entry["title"]} : #{entry["url"]} \n #{entry["description"]}\n\n".red

    #FUD Authors
    fudAuthorCount = chalkUp(fudAuthorCount,entry["author"])

    #FUD Sources
    fudSourceCount = chalkUp(fudSourceCount,entry["source"])

    entryDate = Date.parse(entry["publishedAt"]).to_s
    entry["publishedAt"] = entryDate

    #FUD articles per day
    @fudDates = chalkUp(@fudDates, entryDate)


    @articles.push(entry)

  else
    puts "NOT  #{entry["source"]} - #{entry["author"]} - #{entry["title"]} : #{entry["url"]} \n #{entry["description"]}\n\n".green
  end

  #Total Authors
  authorCount = chalkUp(authorCount,entry["author"])

  #Total Sources
  sourceCount = chalkUp(sourceCount,entry["name"])
end


#Remove blank entries
fudAuthorCount.delete(nil)
fudAuthorCount.delete("")
fudSourceCount.delete(nil)

#Remove newsapi mistakes
notAuthors = ["feedfeeder","The Washington Post, The Washington Post","Reuters","http://www.dailymail.co.uk/home/search.html?s=&authornamef=Reuters","Reuters Editorial","Bloomberg","The Associated Press","Staff reports","ABC News","newsfeeds@nzherald.co.nz","RT"]
notAuthors.each do |na|
  fudAuthorCount.delete(na)
end


puts "Authors"
puts fudAuthorCount.sort_by {|k,v| v}.reverse.map.to_h
puts "Sources"
puts fudSourceCount.sort_by {|k,v| v}.reverse.map.to_h
puts "Dates"
puts @fudDates

#Tally up
dayCount = 0
@fudCount = 0
@fudCountWeek = 0
@fudDates.each do |day,value|
if dayCount < 7
  @fudCountWeek  = @fudCountWeek + value
end
@fudCount = @fudCount + value
dayCount = dayCount + 1
end

#Authors
@fudAuthors = fudAuthorCount.sort_by {|k,v| v}.reverse.map.to_h
@fudSources = fudSourceCount.sort_by {|k,v| v}.reverse.map.to_h

renderer = ERB.new(File.read("index.html.erb"))
html = renderer.result()

File.open("index.html", 'w') do |f|
  f.write(html)
end
