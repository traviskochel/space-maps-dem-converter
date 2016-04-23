class ElevationCalculator
  require 'RMagick'
  include Magick
  require 'pry'
  require 'csv'

  def initialize(planet)
    @planet_opts = {
      mars: {
        name: 'mars',
        max_rows: 32,
        max_cols: 64,
        zoom: 5
      },
      vesta: {
        name: 'vesta',
        max_rows: 16,
        max_cols: 32,
        zoom: 4
      },
      test: {
        name: 'mars',
        max_rows: 1,
        max_cols: 10,
        zoom: 5
      },
    }
    @planet = @planet_opts[planet]
  end

  def start
    CSV.open("../data/#{@planet[:name]}-#{Time.now.to_i}.csv", "wb") do |csv|
      csv << ['row', 'col', 'gray_value']

      @planet[:max_rows].times do |row|
        @planet[:max_cols].times do |col|
          csv << [
            row,
            col,
            self.get_grayscale("../#{@planet[:name]}/#{@planet[:zoom]}/#{row}-#{col}.png")
          ]

        end
      end
    end
  end

  def get_grayscale(file_path)
    image_1 = Magick::Image.read(file_path).first
    image_1.channel_mean.map { |x| x / Magick::QuantumRange }.first
  end

  # CSV.open("file.csv", "wb") do |csv|
  #   csv << ["animal", "count", "price"]
  #   csv << ["fox", "1", "$90.00"]
  # end

  # row
  # col
  # gray_value  

end

ElevationCalculator.new(:mars).start