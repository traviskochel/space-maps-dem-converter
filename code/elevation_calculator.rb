class ElevationCalculator
  require 'RMagick'
  include Magick
  require 'pry'
  require 'csv'
  require 'json'

  def initialize(planet)
    @resolution = 10
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

  def elevation_as_json
    tiles = []
    @planet[:max_rows].times do |row|
      @planet[:max_cols].times do |col|
        file_path = "../images/#{@planet[:name]}/#{@planet[:zoom]}/#{row}-#{col}.png"
        # gray_value: self.get_grayscale(file_path),
        tiles.push({
          row: row,
          col: col,
          pixels: self.get_pixels(file_path)
        })
      end
    end

    planets = []
    planets.push({
      planet: @planet[:name],
      max_rows: @planet[:max_rows],
      max_cols: @planet[:max_cols],
      tiles: tiles,
      resolution: @resolution
    })


    File.open("../data/#{@planet[:name]}-#{Time.now.to_i}.json", "w") do |f|
      f.write planets.to_json
    end
  end

  def get_pixels(file_path)
    image = Magick::Image.read(file_path).first
    small_image = image.resize(@resolution, @resolution)
    pixels = []
    small_image.each_pixel do |pixel|
      pixels.push(
        normalize_color(pixel.red)
      )
    end 
    return pixels
  end

  def normalize_color(color_value)
    color_value / 257.0 / 257
  end

  def get_grayscale(file_path)
    image_1 = Magick::Image.read(file_path).first
    image_1.channel_mean.map { |x| x / Magick::QuantumRange }.first
  end

  def get_image_tile(row, col)
    file_path = "../images/#{@planet[:name]}/#{@planet[:zoom]}/#{row}-#{col}.png"
    Magick::Image.read(file_path).first
  end

  ### machine_learning
  def sum_array(array)
    array.inject { |sum, x| sum + x }
  end

  def deviation(image, col, row, direction)
    if direction == 'horizontal'
      next_col = col + 1
      next_row = row
      last = next_col >= image.columns
    else 
      next_col = col
      next_row = row + 1
      last = next_row >= image.rows
    end

    if !last
      p_0_color = image.pixel_color(col, row).red
      p_1_color = image.pixel_color(next_col, next_row).red
      deviation = (p_0_color - p_1_color).abs
      normalize_color(deviation)
    end
  end

  def neighbor_deviation_values(image)
    deviations = []
    image = image.resize(@resolution, @resolution)
    image.rows.times do |row|
      image.columns.times do |col|
        deviations.push(deviation(image, col, row, 'horizontal'))
        deviations.push(deviation(image, col, row, 'vertical'))
      end
    end
    deviations.compact
  end

  def neighbor_deviations_tile(image, tile_col, tile_row)
    deviations = neighbor_deviation_values(image)
    avg_deviation = sum_array(deviations) / deviations.length

    return {
      col: tile_col,
      row: tile_row,
      avg: avg_deviation,
      max: deviations.max,
      min: deviations.min
    }
  end

  def neighbor_deviations_map
    deviations = []
    @planet[:max_rows].times do |row|
      @planet[:max_cols].times do |col|
        image = get_image_tile(row,col)
        deviations.push(neighbor_deviations_tile(image, col, row))
      end
    end
    deviations
  end


  def vector_deviations_tile(image, tile_col, tile_row)
    deviations = []
    image = image.resize(@resolution, @resolution)
    image.rows.times do |row|
      image.columns.times do |col|
        d_1 = deviation(image, col, row, 'horizontal')
        d_2 = deviation(image, col + 1, row, 'horizontal' )
        if d_1 and d_2
          deviations.push((d_1 - d_2).abs)
        end

        d_3 = deviation(image, col, row, 'vertical')
        d_4 = deviation(image, col, row+1, 'vertical' )
        if d_3 and d_4
          deviations.push((d_3 - d_4).abs)
        end
      end
    end

    avg_deviation = sum_array(deviations) / deviations.length
    return {
      col: tile_col,
      row: tile_row,
      avg: avg_deviation,
      max: deviations.max,
      min: deviations.min
    }
  end

  def vector_deviations
    deviations = []
    @planet[:max_rows].times do |row|
      @planet[:max_cols].times do |col|
        image = get_image_tile(row,col)
        deviations.push(vector_deviations_tile(image, col, row))
      end
    end
    deviations
  end

  def sample
    puts neighbor_deviations_map
    # puts vector_deviations
  end

end

# ElevationCalculator.new(:mars).elevation_as_json
ElevationCalculator.new(:mars).sample