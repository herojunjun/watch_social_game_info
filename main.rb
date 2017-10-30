require 'nokogiri'
require 'yaml'
require 'CGI'

HISTORY_FILE = 'history.txt'

def had_history(url)
  %x(touch #{HISTORY_FILE})
  count = %x(grep -c "#{url}" #{HISTORY_FILE})
  count.to_i != 0
end

def register_history(url)
  %x(touch #{HISTORY_FILE})
  %x(echo "#{url}" >> #{HISTORY_FILE})
end

CONFIG_YAML = 'config.yml'

def notice(data)
  return if had_history(data[:uri])
  config = YAML.load_file(CONFIG_YAML)
  text = CGI.escape("#{data[:title]} : #{data[:uri]}")
  post_api = ["https://slack.com/api/chat.postMessage?",
    "token=", config['token'],
    "&channel=", config['channel'],
    "&text=", text].join('')
  p post_api
  %x(curl "#{post_api}")
  register_history(data[:uri])
end

HOST_URI = "http://gamebiz.jp"
NEW_RELEASE_URI = "http://gamebiz.jp/article/category/5"
body = %x(curl #{NEW_RELEASE_URI})

doc = Nokogiri::HTML.parse(body, nil)

doc.xpath('//div[@class="Article_detail"]/h2/a').each do |node|
  data = {
      :title => node.inner_text,
      :uri => (HOST_URI + node.attribute('href').value)
  }
  notice(data)
end
