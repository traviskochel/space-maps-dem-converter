require "open-uri"

mars = {
  url: "https://api.nasa.gov/mars-wmts/catalog/Mars_MGS_MOLA_DEM_mosaic_global_463m_8/1.0.0/default/default028mm/5/",
  file_type: 'png',
  max_rows: 32,
  max_cols: 64
}
vesta = {
  url: "https://api.nasa.gov/vesta-wmts/catalog/Vesta_Dawn_HAMO_DTM_DLR_Global_48ppd8/1.0.0/default/default028mm/",
  file_type: 'png',
  max_rows: 16,
  max_cols: 32
}

def save_file(row, col, url)
  File.open("tiles/#{row}-#{col}.png", "w") do |f|
    IO.copy_stream(open("#{url}/#{row}/#{col}.png"), f)
  end
end

# mars[:max_rows].times do |row|
#   mars[:max_cols].times do |col|
#     save_file(row, col, mars[:url])
#   end
# end

vesta[:max_rows].times do |row|
  vesta[:max_cols].times do |col|
    save_file(row, col, vesta[:url])
  end
end