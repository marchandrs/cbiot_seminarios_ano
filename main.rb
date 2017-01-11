require "nokogiri"
require "open-uri"
require "openssl"
require "byebug"

def is_seminario_centro(node)
  if node.at_css("p.seminario-lista-categoria").content == "Seminário do CBiot"
    true
  else
    false
  end
end

def is_2016(node)
  if node.at_css("p.seminario-lista-data-local span").content.include? "2016"
    true
  else
    false
  end
end

def get_date(node)
  node.at_css("p.seminario-lista-data-local span").content
end

def get_palestra(node)
  node.css("div.seminario-lista-conteudo p")[1].inner_html
end

def get_palestrante(node)
  node.css("div.seminario-lista-conteudo p")[2].content
end

def get_origem(node)
  node.css("div.seminario-lista-conteudo p")[3].content
end

search = true
page = 1
filename = "lista.html"

File.delete(filename) if File.exist?(filename)

File.open(filename, "w") do |file|
  file.puts '<!doctype html>'
  file.puts '<html lang="en">'
  file.puts '  <head>'
  file.puts '    <meta charset="utf-8">'
  file.puts '      <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">'
  file.puts '  </head>'
  file.puts '  <body>'
  file.puts '    <div class="container" style="margin-top: 50px;">'
end

while search do
  doc = Nokogiri::HTML(open("https://www.ufrgs.br/ppgbcm/seminarios/?pg=#{page}", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))
  doc.css("div.seminario-lista").each do |html|
    search = is_2016(html)
    next unless is_seminario_centro(html) && is_2016(html)

    File.open(filename, "a") do |file|
      file.puts "<p>"
      file.puts get_date(html) << "<br>"
      file.puts get_palestra(html) << "<br>"
      file.puts get_palestrante(html) << "<br>"
      file.puts get_origem(html)
      #file.puts "<hr>"
      file.puts "</p>"
    end
  end

  page = page + 1
  search = false if page > 2
end

File.open(filename, "a") do |file|
  file.puts '    </div>'
  file.puts '  </body>'
  file.puts '</html>'
end
