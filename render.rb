require 'news-api'
require 'date'
require 'erb'

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
fudwords = /desperate|rattled|trouble|fear|scare|doom|bankrupt|losing faith|concerns/

scanDate = DateTime.now.to_date.to_s

jsonData.each do |entry|
  if (entry["description"]  =~ fudwords || entry["title"]  =~ fudwords) && (entry["description"]  =~ definitelyTesla || entry["title"] =~ definitelyTesla)

    puts "Fud from #{entry["name"]} - #{entry["title"]} : #{entry["url"]} \n #{entry["description"]}\n\n"

    #FUD Authors
    fudAuthorCount = chalkUp(fudAuthorCount,entry["author"])

    #FUD Sources
    fudSourceCount = chalkUp(fudSourceCount,entry["source"])

    entryDate = Date.parse(entry["publishedAt"]).to_s
    #FUD articles per day
    @fudDates = chalkUp(@fudDates, entryDate)

    @articles.push("#{entryDate} #{entry["source"]} - #{entry["title"]}")

  end

  #Total Authors
  authorCount = chalkUp(authorCount,entry["author"])

  #Total Sources
  sourceCount = chalkUp(sourceCount,entry["name"])
end


#Remove blank entries
fudAuthorCount.delete(nil)
fudSourceCount.delete(nil)

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
