require './common'
require 'graph-rank'
require 'stopwords'
require 'statsample'

module Exercise2
  extend self

  PageRank = GraphRank::PageRank

  def run(size)
    damping ||= 0.85; convergence ||= 0.01
    pr = PageRank.new(damping, convergence)
    json = Common.downloadPushShift("depression", size)
    puts "Adding nodes to graph"
    json["hits"]["hits"].each do |i|
      text_string = Common.clean_text(i["_source"]["selftext"])
      if (text_string.nil?)
        text = []
      else
        text = text_string&.scan(/[-'\w]+/)
        text = clean_up_array(text)
      end
      addNodes(text = text, pr = pr)
    end
    puts "Calculating PageRank... Wait for convergence"
    nodes = pr.calculate
    puts "Save to CSV"
    CSV.open("textrank#{size}.csv", "wb") {|csv| nodes.each {|elem| csv << elem}}
    puts "Finished Exercise 2"
  end


  def clean_up_array(array)
    # Remove numbers
    array.each do |k|
      if /\A\d+\z/.match(k)
        array.delete(k)
      end
    end

    # Discard words with special chars
    array.each do |k|
      special = "?<>',?[]}{=-)(*&^%$#`~{}"
      regex = /[#{special.gsub(/./) {|char| "\\#{char}"}}]/
      if (k =~ regex)
        array.delete(k)
      end
    end
    # Short words (less or eq 2 in length) dont have much semantics in english or maybe single letter (I, we, of, my...)
    array.delete_if {|k| k.length <= 2}
    # Delete strange blank char
    array.delete("x200b")
    # Clean URLS
    array.delete_if {|k| k.start_with?("http")}
    # Filter StopWords
    filter = Stopwords::Snowball::Filter.new "en"
    array = filter.filter array
    array
  end

# @param [Integer] sentence_size
# @param [String] text

# @param [PageRank] pr
  def addNodes(sentence_size = 8, text, pr)
    text.each_with_index do |f, i|
      j = i + sentence_size
      while i < j
        # Check if it is out of bounds
        unless (text[j].nil?)
          # Bidirectional relation
          pr.add(text[i], text[j])
          pr.add(text[j], text[i])
        end
        j -= 1
      end
    end
  end


  def spearman_compare(textrank, rootLLR)
    # Create two lists of value orders
    v1 = []
    v2 = []
    textrank.each do |k, v|
      r = rootLLR[k]
      unless r.nil?
        v1 << v
        v2 << r
      end
    end

    Statsample::Bivariate.spearman(Daru::Vector.new(v1), Daru::Vector.new(v2))
  end

end