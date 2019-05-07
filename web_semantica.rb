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
    textrank = WebSemantica.loadCSV("/textrank#{size}.csv")
    rootLLR = WebSemantica.loadCSV("/rootLLR#{size}.csv")
    puts Exercise2::spearman_compare(textrank, rootLLR)
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


WebSemantica.new(80)