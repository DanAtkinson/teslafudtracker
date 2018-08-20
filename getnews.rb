require 'news-api'
require 'date'

n = News.new(IO.read("apikey.txt").strip)

#fileData = IO.read("data.json")
#jsonData = JSON.parse(fileData)

@articles = Array.new

definitelyTesla = /[Tt]esla|[Mm]usk|[Ee]lon/
fudwords = /desperate|rattled|trouble|fear|scare|doom|bankrupt|losing faith|concerns/

scanDate = DateTime.now.to_date.to_s
entryDate = scanDate
begin
  for i in 1..5 do
    for page in 1..99 do
      e = n.get_everything(q: "tesla", sortBy: "publishedAt", pageSize: 100, to: scanDate, language: "en", page: page)
      puts "get everything.."
      e.each do |entry|
          puts "#{entry.name} -  #{entry.title}"
          @articles.push({"source" => entry.name,"author" => entry.author , "title" => entry.title, "url" => entry.url, "description" => entry.description, "publishedAt" => entry.publishedAt })
          entryDate = Date.parse(entry.publishedAt).to_s
      end
    end
  puts "query again for entries newer than #{entryDate}"
  scanDate = entryDate
  end
rescue
  puts "Exausted our limit for today"
end

File.open("data.json","w") do |f|
  f.write(@articles.to_json)
end
