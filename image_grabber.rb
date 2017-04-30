require 'mechanize'
require 'pry'
require 'csv'
require 'fileutils'
require 'tempfile'
names = []
CSV.foreach("data/religious_buildings_copy.csv", headers: true) do |row|
  names << row.fetch("name")
end

image_urls = []
descriptions = []

names.each do |name|
  puts "getting image url for #{name}"
  a = Mechanize.new

  search_params = name.gsub(" ","+") + "+Baltimore+MD"
  url = "http://en.wikipedia.org/wiki/Special:Search?search=#{search_params}&go=Go"

  page = a.get url
  if page.body =~ /There were no results matching the query./
    image_full_url = "http://visioncame.com/images/notfound.jpg"
    description = "Bacon ipsum dolor amet ball tip pig ribeye chicken pastrami jerky porchetta shank frankfurter capicola jowl corned beef turkey. Burgdoggen pork loin jerky biltong shank capicola. Doner rump leberkas tongue. T-bone tri-tip meatball cupim pork belly. Tenderloin pork ribeye, frankfurter alcatra ham hock cow picanha swine filet mignon ground round kielbasa short loin jerky ball tip. Brisket jowl capicola chicken beef ribs leberkas ground round filet mignon pork spare ribs tri-tip shankle sausage meatball."
  else
    begin
    url_end = page.css("div.mw-search-result-heading").first.children.first.attributes.fetch("href").value

    object_url = "https://en.wikipedia.org#{url_end}"

    page = a.get object_url
    description = page.css("div#mw-content-text.mw-content-ltr p").first.text

    image_url_end = page.css("a.image").first.children.first.attributes.fetch("src").value
  rescue
    image_full_url = "http://visioncame.com/images/notfound.jpg"
  end
    image_full_url = "http:#{image_url_end}"
  end
  image_urls << image_full_url
  descriptions << description
end
image_urls.unshift("image_urls")
descriptions.unshift("description")
puts "HI"
temp = Tempfile.new("csv")
CSV.open(temp,"w") do |temp_csv|
  CSV.foreach("data/religious_buildings_copy.csv").with_index do |orig, i|
    temp_csv << orig + [image_urls[i]] + [descriptions[i]]
  end
end

FileUtils.mv(temp, "data/religious_buildings.csv", :force => true)
