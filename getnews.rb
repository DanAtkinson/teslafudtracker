require 'news-api'
require 'date'
require 'set'

n = News.new(IO.read("apikey.txt").strip)

#fileData = IO.read("data.json")
#jsonData = JSON.parse(fileData)

duplicateCheck = Set.new
@articles = Array.new

definitelyTesla = /[Tt]esla|[Mm]usk|[Ee]lon/
fudwords = /desperate|rattled|trouble|fear|scare|doom|bankrupt|losing faith|concerns/

scanDate = DateTime.now
entryDate = scanDate
newArticles = true
begin
  while newArticles do
    for page in 1..10 do
      #2018-09-13T11:27:40 .iso8601
      e = n.get_everything(q: "tesla", sortBy: "publishedAt", pageSize: 100, to: scanDate.strftime('%F'), language: "en", page: page)
      puts "get everything from #{scanDate.strftime('%F')} - records: #{e.size}"

      if e.size == 0
        newArticles = false
        break
      end

      e.each do |entry|
          sourceAndTitle = "#{entry.publishedAt} #{entry.name} -  #{entry.title}"
          unless duplicateCheck.include?(sourceAndTitle)
            puts sourceAndTitle
            duplicateCheck.add(sourceAndTitle)
            @articles.push({"source" => entry.name,"author" => entry.author , "title" => entry.title, "url" => entry.url, "description" => entry.description, "publishedAt" => entry.publishedAt, "urlToImage" => entry.urlToImage })
            entryDate = DateTime.parse(entry.publishedAt)
          end
      end
    end
  puts "query again for entries newer than #{entryDate}"
  scanDate = entryDate.to_date
  end
rescue => exception
  puts "Exausted our limit for today "
end

File.open("data.json","w") do |f|
  f.write(@articles.to_json)
end
