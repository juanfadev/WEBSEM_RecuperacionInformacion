require './exercise2'
require './exercise1'

class WebSemantica
  def initialize(size)
    @size = size
    self.exercise2_spearman
    #self.exercise1
    #self.exercise2_pagerank

  end

  def exercise1
    Exercise1::run(@size)
  end

  def exercise2_pagerank
    Exercise2::run(@size)
  end

  def exercise2_spearman(size = @size)
    # Load both CSV
    textrank =  begin
      WebSemantica.loadCSV("/textrank#{size}.csv")
    rescue
      self.exercise2_pagerank
      WebSemantica.loadCSV("/textrank#{size}.csv")
    end
    rootLLR = begin
      WebSemantica.loadCSV("/rootLLR#{size}.csv")
    rescue
      self.exercise1
      WebSemantica.loadCSV("/rootLLR#{size}.csv")
    end
    puts "The spearman ratio with the last #{size} posts is: #{Exercise2::spearman_compare(textrank, rootLLR)}"
  end

  def self.loadCSV(path)
    file = File.join(File.dirname(File.expand_path(__FILE__)), path)
    table = CSV.open(file)
    tableHash = {}
    table.each_with_index do |r, i|
      tableHash[r[0]] = i
    end
    return tableHash
  end
end

args = Hash[ ARGV.flat_map{|s| s.scan(/--?([^=\s]+)(?:=(\S+))?/) } ]

WebSemantica.new(args['size'])