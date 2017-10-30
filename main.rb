require 'nokogiri'

HOST_URI = "http://gamebiz.jp"
NEW_RELEASE_URI = "http://gamebiz.jp/article/category/5"
body = %x(curl #{NEW_RELEASE_URI})

doc = Nokogiri::HTML.parse(body, nil)

doc.xpath('//div[@class="Article_detail"]/h2/a').each do |node|
  data = {
      :title => node.inner_text,
      :uri => (HOST_URI + node.attribute('href').value)
  }
  p data
end
